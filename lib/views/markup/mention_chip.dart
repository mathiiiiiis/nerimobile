import 'dart:math';

import 'package:flutter/material.dart';

import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';

class MentionChip extends StatelessWidget {
  const MentionChip({super.key, required this.label, this.leading, this.color});

  final String label;
  final Widget? leading;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final sizing = context.neriSize;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sizing.space(NeriSpacingRole.xs),
      ),
      decoration: BoxDecoration(
        color: context.neri[NeriToken.markupMentionBackground],
        borderRadius: BorderRadius.circular(sizing.radius(NeriRadiusRole.full)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: sizing.space(NeriSpacingRole.xs),
        children: [
          ?leading,
          Text(label, style: TextStyle(color: color)),
        ],
      ),
    );
  }
}

Size mentionChipSize({
  required String label,
  required double leadingSize,
  required double spacing,
  required TextStyle style,
  required TextScaler textScaler,
  required TextDirection textDirection,
}) {
  final painter = TextPainter(
    text: TextSpan(text: label, style: style),
    textDirection: textDirection,
    textScaler: textScaler,
  )..layout();

  final leading = leadingSize > 0 ? leadingSize + spacing : 0;
  final size = Size(
    spacing * 2 + leading + painter.width,
    max(leadingSize, painter.height),
  );
  painter.dispose();

  return size;
}
