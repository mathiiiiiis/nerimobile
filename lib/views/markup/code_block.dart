import 'package:flutter/material.dart';

import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';

class CodeBlockView extends StatelessWidget {
  const CodeBlockView({super.key, required this.code, this.lang});

  final InlineSpan code;
  final String? lang;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sizing.space(NeriSpacingRole.sm)),
      decoration: BoxDecoration(
        color: colors[NeriToken.markupCodeBackground],
        borderRadius: sizing.rounded(NeriRadiusRole.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: sizing.space(NeriSpacingRole.xs),
        children: [
          if (lang case final lang? when lang.isNotEmpty)
            Text(
              lang,
              style: context.neriText[NeriTextRole.labelSmall].copyWith(
                color: colors[NeriToken.textTertiary],
              ),
            ),
          Text.rich(code, style: context.neriText.mono),
        ],
      ),
    );
  }
}
