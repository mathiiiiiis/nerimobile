import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nerimobile/router/slide_over_page.dart';
import 'package:nerimobile/stores/auth/auth_store.dart';
import 'package:nerimobile/views/auth/login_page.dart';
import 'package:nerimobile/views/chat/channel_pane.dart';
import 'package:nerimobile/views/dashboard/dashboard_pane.dart';
import 'package:nerimobile/views/shell/app_scaffold.dart';
import 'package:nerimobile/views/shell/destinations.dart';
import 'package:nerimobile/views/shell/widgets/panes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref.listen(authProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
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
              GoRoute(
                path: '/app',
                pageBuilder: (_, _) => const StaticPage(child: DashboardPane()),
                routes: [
                  GoRoute(
                    path: 'inbox/:channelId',
                    pageBuilder: (_, state) => SlideOverPage(
                      child: ChannelPane(
                        channelId: state.pathParameters['channelId']!,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/servers',
                builder: (_, _) => const AppScaffold(
                  branch: NeriBranch.servers,
                  listPane: PlaceholderPane(label: 'Channels'),
                  content: PlaceholderPane(label: 'No server'),
                ),
              ),
              GoRoute(
                path: '/app/servers/:serverId',
                builder: (_, _) => const AppScaffold(
                  branch: NeriBranch.servers,
                  listPane: PlaceholderPane(label: 'Channels'),
                  content: PlaceholderPane(label: 'Server'),
                ),
                routes: [
                  GoRoute(
                    path: ':channelId',
                    builder: (_, state) => AppScaffold(
                      branch: NeriBranch.servers,
                      listPane: const PlaceholderPane(label: 'Channels'),
                      content: PlaceholderPane(
                        label: 'channel ${state.pathParameters['channelId']}',
                      ),
                    ),
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
});

String? _redirect(Ref ref, String location) {
  final auth = ref.read(authProvider);
  if (auth.isLoading) return location == '/' ? null : '/';

  if (auth.value == null) return location == '/login' ? null : '/login';
  return location == '/login' || location == '/' ? '/app' : null;
}
