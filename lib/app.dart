import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/presets/presets.dart';
import 'package:nerimobile/theme/sizing/breakpoints.dart';

import 'package:nerimobile/utils/theme_notifier.dart';
import 'package:nerimobile/views/window_focus_observer.dart';
import 'package:nerimobile/router.dart';

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = buildNeriTheme(spec: presetById(defaultPresetId));

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: true,
          theme: theme,
          darkTheme: theme,
          themeMode: mode,
          routerConfig: ref.watch(routerProvider),
          builder: (context, child) => FocusObserver(
            child: NeriWindowScope(
              child: Scaffold(resizeToAvoidBottomInset: true, body: child!),
            ),
          ),
        );
      },
    );
  }
}
