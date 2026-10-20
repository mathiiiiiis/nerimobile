import 'package:flutter/material.dart';

import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/border.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';

const _reveal = Duration(milliseconds: 200);
const _maxCount = 99;

class ScrollJumpButton extends StatelessWidget {
  const ScrollJumpButton({
    super.key,
    required this.shown,
    required this.icon,
    required this.onTap,
    this.count = 0,
  });

  final bool shown;
  final IconData icon;
  final VoidCallback onTap;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final size = sizing.dimen(NeriDimen.controlSize);
    final radius = sizing.rounded(NeriRadiusRole.md);

    return AnimatedScale(
      scale: shown ? 1 : 0,
      duration: _reveal,
      curve: Curves.easeOutBack,
      child: IgnorePointer(
        ignoring: !shown,
        child: Material(
          color: colors[NeriToken.text],
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(
              color: colors[NeriToken.border],
              width: sizing.border(NeriBorderRole.hairline),
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: size, minHeight: size),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: count > 0 ? sizing.space(NeriSpacingRole.sm) : 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: sizing.space(NeriSpacingRole.xs),
                  children: [
                    if (count > 0)
                      Text(
                        count > _maxCount ? '$_maxCount+' : '$count',
                        style: context.neriText[NeriTextRole.labelLarge]
                            .copyWith(color: colors[NeriToken.primary]),
                      ),
                    Icon(
                      icon,
                      size: sizing.dimen(NeriDimen.iconSm),
                      color: colors[NeriToken.primary],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
