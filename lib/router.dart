import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (_, _) => const Scaffold(body: Center(child: Text('login'))),
    ),
    GoRoute(
      path: '/app',
      builder: (_, _) => const Scaffold(body: Center(child: Text('app'))),
    ),
  ],
);
