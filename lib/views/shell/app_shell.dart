import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/breakpoints.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';
import 'package:nerimobile/views/shell/destinations.dart';
import 'package:nerimobile/views/shell/widgets/nav_bar.dart';
import 'package:nerimobile/views/shell/widgets/nav_rail.dart';
import 'package:nerimobile/views/shell/widgets/panes.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final windowClass = NeriWindow.of(context);
    final sizing = context.neriSize;
    final branch = NeriBranch.values[navigationShell.currentIndex];

    return Column(
      children: [
        _Header(label: branch.name, height: windowClass.headerHeight),
        Expanded(
          child: Row(
            children: [
              NavRail(branch: branch, onSelect: (d) => _select(context, d)),
              if (windowClass.isDualPane)
                SizedBox(
                  width: sizing.dimen(NeriDimen.listPaneWidth),
                  child: ListPane(branch: branch),
                ),
              Expanded(child: navigationShell),
            ],
          ),
        ),
        if (windowClass.destinationsInBottomBar)
          NavBar(branch: branch, onSelect: (d) => _select(context, d)),
      ],
    );
  }

  void _select(BuildContext context, NeriDestination destination) {
    switch (destination) {
      case BranchDestination(:final branch):
        navigationShell.goBranch(
          branch.index,
          initialLocation: branch.index == navigationShell.currentIndex,
        );
      case PageDestination(:final path):
        context.push(path);
      case AvatarDestination():
        showProfileMenu(context);
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.label, required this.height});

  final String label;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;

    return ColoredBox(
      color: colors[NeriToken.headerBlurDisabled],
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: height,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: sizing.space(NeriSpacingRole.md),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: context.neriText[NeriTextRole.titleLarge].copyWith(
                  color: colors[NeriToken.text],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
