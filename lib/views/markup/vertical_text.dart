import 'package:flutter/material.dart';

import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';

class VerticalText extends StatelessWidget {
  const VerticalText({super.key, required this.lines, required this.style});

  final List<String> lines;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      //needed for vertical-rl column ordering
      textDirection: TextDirection.rtl,
      spacing: context.neriSize.space(NeriSpacingRole.xs),
      children: [
        for (final line in lines)
          RotatedBox(quarterTurns: 1, child: Text(line, style: style)),
      ],
    );
  }
}
