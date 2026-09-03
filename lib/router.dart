import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:nerimobile/views/dev/token_gallery.dart';

final router = GoRouter(
  initialLocation: kDebugMode ? '/dev/tokens' : '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (_, _) => const Scaffold(body: Center(child: Text('login'))),
    ),
    GoRoute(
      path: '/app',
      builder: (_, _) => const Scaffold(body: Center(child: Text('app'))),
    ),
    if (kDebugMode)
      GoRoute(path: '/dev/tokens', builder: (_, _) => const TokenGallery()),
  ],
);
