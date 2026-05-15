import 'package:go_router/go_router.dart';
import 'package:nerimobile/views/login/login.dart';
import 'package:nerimobile/views/shell/app_shell.dart';
import 'package:nerimobile/views/app/message_content/message_content.dart';
import 'package:flutter/material.dart';

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: "/login", builder: (ctx, state) => const LoginPage()),
    ShellRoute(
      builder: (ctx, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/app', builder: (ctx, state) => const SizedBox.shrink()),
        ShellRoute(
          builder: (ctx, state, child) => ChatLayout(child: child),
          routes: [
            GoRoute(
              path: '/app/servers/:serverId/:channelId',
              builder: (_, state) => MessageContent(
                serverId: state.pathParameters['serverId']!,
                channelId: state.pathParameters['channelId']!,
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);
