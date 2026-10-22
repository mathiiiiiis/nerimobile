import 'package:flutter/widgets.dart';

import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/border.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.message, this.hint, this.icon});

  final String message;
  final String? hint;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final text = context.neriText;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sizing.space(NeriSpacingRole.lg)),
      decoration: BoxDecoration(
        color: colors[NeriToken.card],
        borderRadius: sizing.rounded(NeriRadiusRole.lg),
        border: Border.all(
          color: colors[NeriToken.border],
          width: sizing.border(NeriBorderRole.hairline),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: sizing.space(NeriSpacingRole.xs),
        children: [
          if (icon case final icon?)
            Icon(
              icon,
              size: sizing.dimen(NeriDimen.iconMd),
              color: colors[NeriToken.textTertiary],
            ),
          Text(
            message,
            textAlign: TextAlign.center,
            style: text[NeriTextRole.bodyMedium].copyWith(
              color: colors[NeriToken.textPlaceholder],
            ),
          ),
          if (hint case final hint?)
            Text(
              hint,
              textAlign: TextAlign.center,
              style: text[NeriTextRole.bodySmall].copyWith(
                color: colors[NeriToken.textTertiary],
              ),
            ),
        ],
      ),
    );
  }
}
