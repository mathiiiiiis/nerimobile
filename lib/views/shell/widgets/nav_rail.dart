import 'package:flutter/material.dart';

import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/breakpoints.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/views/shell/destinations.dart';
import 'package:nerimobile/views/shell/widgets/destination_icon.dart';
import 'package:nerimobile/views/shell/widgets/scroll_fade.dart';

class NavRail extends StatelessWidget {
  const NavRail({super.key, required this.branch, required this.onSelect});

  final NeriBranch branch;
  final ValueChanged<NeriDestination> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;

    return Container(
      width: sizing.dimen(NeriDimen.railWidth),
      color: colors[NeriToken.rail],
      child: Column(
        children: [
          Expanded(
            child: ScrollFade(
              color: colors[NeriToken.rail],
              child: ListView.builder(
                padding: EdgeInsets.only(
                  top: sizing.space(NeriSpacingRole.sm),
                  bottom: sizing.dimen(NeriDimen.fadeHeight),
                ),
                itemCount: 12,
                itemBuilder: (context, _) => const _ServerPlaceholder(),
              ),
            ),
          ),
          if (NeriWindow.of(context).destinationsInRail)
            SafeArea(
              top: false,
              right: false,
              child: Column(
                children: [
                  for (final destination in neriDestinations)
                    _RailItem(
                      destination: destination,
                      selected:
                          destination is BranchDestination &&
                          destination.branch == branch,
                      size: sizing.dimen(NeriDimen.controlSize),
                      onTap: () => onSelect(destination),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ServerPlaceholder extends StatelessWidget {
  const _ServerPlaceholder();

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final size = sizing.dimen(NeriDimen.avatarMd);

    return Padding(
      padding: EdgeInsets.only(bottom: sizing.space(NeriSpacingRole.sm)),
      child: Center(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: colors[NeriToken.avatarPlaceholder],
            shape: BoxShape.circle,
            border: Border.all(
              color: colors[NeriToken.border],
              width: sizing.dimen(NeriDimen.avatarRingWidth),
            ),
          ),
        ),
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.destination,
    required this.selected,
    required this.size,
    required this.onTap,
  });

  final NeriDestination destination;
  final bool selected;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;

    return Padding(
      padding: EdgeInsets.only(top: sizing.space(NeriSpacingRole.xs)),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: selected
                ? colors[NeriToken.navIndicator]
                : Colors.transparent,
            borderRadius: sizing.rounded(NeriRadiusRole.xl),
          ),
          child: DestinationIcon(
            destination: destination,
            selected: selected,
            size: size,
            surface: colors[NeriToken.rail],
          ),
        ),
      ),
    );
  }
}
