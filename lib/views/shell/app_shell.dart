import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:nerimobile/views/shell/app_scaffold.dart';
import 'package:nerimobile/views/shell/destinations.dart';
import 'package:nerimobile/views/shell/widgets/panes.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final branch = NeriBranch.values[navigationShell.currentIndex];

    return AppScaffold(
      branch: branch,
      listPane: ListPane(branch: branch),
      content: navigationShell,
    );
  }
}
