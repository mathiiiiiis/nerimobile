import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nerimobile/router/slide_over_page.dart';
import 'package:nerimobile/stores/auth/auth_store.dart';
import 'package:nerimobile/stores/channel/last_opened_store.dart';
import 'package:nerimobile/theme/sizing/breakpoints.dart';
import 'package:nerimobile/views/auth/login_page.dart';
import 'package:nerimobile/views/chat/channel/channel_pane.dart';
import 'package:nerimobile/views/dashboard/dashboard_pane.dart';
import 'package:nerimobile/views/dashboard/dm_list.dart';
import 'package:nerimobile/views/server/channel_list.dart';
import 'package:nerimobile/views/server/member_list.dart';
import 'package:nerimobile/views/shell/app_scaffold.dart';
import 'package:nerimobile/views/shell/destinations.dart';
import 'package:nerimobile/views/shell/widgets/panes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref.listen(authProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (_, state) => _redirect(ref, state.matchedLocation),
    routes: [
      GoRoute(path: '/', builder: (_, _) => const SizedBox.shrink()),
      GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
      GoRoute(
        path: '/app/settings',
        builder: (_, _) => const PlaceholderPane(label: 'Settings'),
        routes: [
          GoRoute(
            path: ':section',
            builder: (_, state) =>
                PlaceholderPane(label: state.pathParameters['section']!),
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) => navigationShell,
        branches: [
          StatefulShellBranch(
            routes: [
              _dualPaneShell(
                branch: NeriBranch.dashboard,
                listPane: (_) => const DmListPane(),
                routes: [
                  GoRoute(
                    path: '/app',
                    pageBuilder: (_, _) =>
                        const StaticPage(child: DashboardPane()),
                    routes: [
                      GoRoute(
                        path: 'inbox/:channelId',
                        pageBuilder: (context, state) => _channelPage(
                          context,
                          ChannelPane(
                            channelId: state.pathParameters['channelId']!,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              _dualPaneShell(
                branch: NeriBranch.servers,
                listPane: (state) => switch (state.pathParameters['serverId']) {
                  final serverId? => ChannelListPane(
                    key: ValueKey(serverId),
                    serverId: serverId,
                    selectedChannelId: state.pathParameters['channelId'],
                  ),
                  null => const PlaceholderPane(label: 'Channels'),
                },
                routes: [
                  GoRoute(
                    path: '/app/servers',
                    builder: (context, state) => _branchPage(
                      context,
                      NeriBranch.servers,
                      const PlaceholderPane(label: 'No server'),
                    ),
                  ),
                  GoRoute(
                    path: '/app/servers/:serverId',
                    builder: (context, state) {
                      final serverId = state.pathParameters['serverId']!;
                      return _branchPage(
                        context,
                        NeriBranch.servers,
                        //the list is the page on mobile
                        NeriWindow.of(context).isDualPane
                            ? const PlaceholderPane(label: 'Server')
                            : ChannelListPane(
                                key: ValueKey(serverId),
                                serverId: serverId,
                              ),
                      );
                    },
                    routes: [
                      GoRoute(
                        path: ':channelId',
                        pageBuilder: (context, state) => _channelPage(
                          context,
                          ChannelPane(
                            channelId: state.pathParameters['channelId']!,
                            serverId: state.pathParameters['serverId']!,
                          ),
                        ),
                        routes: [
                          GoRoute(
                            path: 'members',
                            pageBuilder: (_, state) => SlideOverPage(
                              child: MembersPage(
                                serverId: state.pathParameters['serverId']!,
                                channelId: state.pathParameters['channelId']!,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/explore',
                redirect: (_, _) => '/app/explore/servers',
              ),
              GoRoute(
                path: '/app/explore/:section',
                builder: (_, state) => AppScaffold(
                  branch: NeriBranch.explore,
                  listPane: const PlaceholderPane(label: 'Explore sections'),
                  content: PlaceholderPane(
                    label: 'explore ${state.pathParameters['section']}',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  String? rememberedPath;
  void remember() {
    final state = router.state;
    if (state.uri.path == rememberedPath) return;
    rememberedPath = state.uri.path;

    final lastOpened = ref.read(lastOpenedProvider.notifier);
    switch (state.pathParameters) {
      case {'serverId': final serverId, 'channelId': final channelId}:
        lastOpened.openServerChannel(serverId, channelId);
      case {'channelId': final channelId}:
        lastOpened.openInbox(channelId);
    }
  }

  router.routerDelegate.addListener(remember);
  ref.onDispose(() => router.routerDelegate.removeListener(remember));

  return router;
});

ShellRoute _dualPaneShell({
  required NeriBranch branch,
  required Widget Function(GoRouterState state) listPane,
  required List<RouteBase> routes,
}) => ShellRoute(
  builder: (context, state, child) => NeriWindow.of(context).isDualPane
      ? AppScaffold(branch: branch, listPane: listPane(state), content: child)
      : child,
  routes: routes,
);

Widget _branchPage(BuildContext context, NeriBranch branch, Widget content) =>
    NeriWindow.of(context).isDualPane
    ? content
    : AppScaffold(branch: branch, content: content);

Page<void> _channelPage(BuildContext context, Widget pane) =>
    NeriWindow.of(context).isDualPane
    ? StaticPage(child: pane)
    : SlideOverPage(child: pane);

String? _redirect(Ref ref, String location) {
  final auth = ref.read(authProvider);
  if (auth.isLoading) return location == '/' ? null : '/';

  if (auth.value == null) return location == '/login' ? null : '/login';
  return location == '/login' || location == '/' ? '/app' : null;
}
