import 'package:flutter/material.dart';

import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/border.dart';
import 'package:nerimobile/theme/sizing/breakpoints.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';

class ComposerPanelFrame extends StatelessWidget {
  const ComposerPanelFrame({
    super.key,
    required this.child,
    this.expansion = 1,
  });

  final Widget child;
  final double expansion;

  @override
  Widget build(BuildContext context) {
    final sizing = context.neriSize;
    final gap = sizing.space(NeriSpacingRole.sm);
    final dual = NeriWindow.of(context).isDualPane;
    final radius = Radius.circular(
      dual
          ? sizing.radius(NeriRadiusRole.image)
          : sizing.radius(NeriRadiusRole.xl) * expansion,
    );

    return Container(
      margin: dual ? EdgeInsets.fromLTRB(gap, 0, gap, gap) : EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.neri[NeriToken.pane],
        borderRadius: dual
            ? BorderRadius.all(radius)
            : BorderRadius.only(topLeft: radius, topRight: radius),
        border: dual
            ? Border.all(
                color: context.neri[NeriToken.border],
                width: sizing.border(NeriBorderRole.hairline),
              )
            : null,
      ),
      child: SafeArea(
        top: false,
        bottom: !dual,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            gap,
            dual ? gap : gap * expansion,
            gap,
            gap,
          ),
          child: child,
        ),
      ),
    );
  }
}
