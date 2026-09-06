import 'package:flutter/material.dart';

import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/views/shell/destinations.dart';
import 'package:nerimobile/views/shell/widgets/destination_icon.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key, required this.branch, required this.onSelect});

  final NeriBranch branch;
  final ValueChanged<NeriDestination> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;

    return ColoredBox(
      color: colors[NeriToken.navBackground],
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: sizing.space(NeriSpacingRole.sm),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final destination in neriDestinations)
                _NavItem(
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
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: DestinationIcon(
        destination: destination,
        selected: selected,
        size: size,
        surface: context.neri[NeriToken.rail],
      ),
    );
  }
}
