import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nerimobile/stores/auth/auth_store.dart';
import 'package:nerimobile/views/shell/app_shell.dart';
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
      GoRoute(
        path: '/login',
        builder: (_, _) => const Scaffold(body: Center(child: Text('login'))),
      ),
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
        builder: (_, _, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app',
                builder: (_, _) => const PlaceholderPane(label: 'Dashboard'),
                routes: [
                  GoRoute(
                    path: 'inbox/:channelId',
                    builder: (_, state) => PlaceholderPane(
                      label: 'dm ${state.pathParameters['channelId']}',
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
                builder: (_, _) => const PlaceholderPane(label: 'No server'),
              ),
              GoRoute(
                path: '/app/servers/:serverId',
                builder: (_, _) => const PlaceholderPane(label: 'Server'),
                routes: [
                  GoRoute(
                    path: ':channelId',
                    builder: (_, state) => PlaceholderPane(
                      label: 'channel ${state.pathParameters['channelId']}',
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
                builder: (_, state) => PlaceholderPane(
                  label: 'explore ${state.pathParameters['section']}',
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
