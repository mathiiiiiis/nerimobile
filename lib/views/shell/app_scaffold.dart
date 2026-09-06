import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nerimobile/stores/dashboard/dashboard_page_store.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/breakpoints.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';
import 'package:nerimobile/views/shell/destinations.dart';
import 'package:nerimobile/views/shell/widgets/connection_banner.dart';
import 'package:nerimobile/views/shell/widgets/nav_bar.dart';
import 'package:nerimobile/views/shell/widgets/nav_rail.dart';
import 'package:nerimobile/views/shell/widgets/panes.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.branch,
    required this.content,
    this.listPane,
  });

  final NeriBranch branch;
  final Widget content;
  final Widget? listPane;

  @override
  Widget build(BuildContext context) {
    final windowClass = NeriWindow.of(context);
    final sizing = context.neriSize;
    final pane = windowClass.isDualPane ? listPane : null;

    return Column(
      children: [
        _Header(branch: branch, height: windowClass.headerHeight),
        Expanded(
          child: Row(
            children: [
              NavRail(branch: branch, onSelect: (d) => _select(context, d)),
              Expanded(
                child: _ContentSurface(
                  child: Row(
                    children: [
                      if (pane != null)
                        SizedBox(
                          width: sizing.dimen(NeriDimen.listPaneWidth),
                          child: pane,
                        ),
                      Expanded(child: content),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (windowClass.destinationsInBottomBar)
          NavBar(branch: branch, onSelect: (d) => _select(context, d)),
      ],
    );
  }

  void _select(BuildContext context, NeriDestination destination) {
    final shell = StatefulNavigationShell.of(context);

    switch (destination) {
      case BranchDestination(:final branch):
        shell.goBranch(
          branch.index,
          initialLocation: branch.index == shell.currentIndex,
        );
      case PageDestination(:final path):
        context.push(path);
      case AvatarDestination():
        showProfileMenu(context);
    }
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.branch, required this.height});

  final NeriBranch branch;
  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final label =
        branch == NeriBranch.dashboard && !NeriWindow.of(context).isDualPane
        ? ref.watch(dashboardPageProvider).label
        : branch.label;

    return ColoredBox(
      color: colors[NeriToken.background],
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: height,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: sizing.space(NeriSpacingRole.md),
            ),
            child: Row(
              children: [
                Text(
                  label,
                  style: context.neriText[NeriTextRole.titleLarge].copyWith(
                    color: colors[NeriToken.text],
                  ),
                ),
                const Spacer(),
                //TODO: everything pushed over shell has the banner hidden there
                const ConnectionBanner(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContentSurface extends StatelessWidget {
  const _ContentSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = Radius.circular(context.neriSize.radius(NeriRadiusRole.xl));

    return ClipRRect(
      borderRadius: BorderRadius.only(topLeft: radius, bottomLeft: radius),
      child: ColoredBox(color: context.neri[NeriToken.pane], child: child),
    );
  }
}
