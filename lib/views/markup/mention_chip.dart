import 'dart:math';

import 'package:flutter/material.dart';

import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/sizing/radius.dart';

const mentionLeadingSize = 16.0;
const mentionIconSize = 14.0;
const _gap = 4.0;
const _padding = 4.0;
const _background = Color.fromARGB(28, 255, 255, 255);

class MentionChip extends StatelessWidget {
  const MentionChip({super.key, required this.leading, required this.label});

  final Widget leading;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: _padding),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(
          context.neriSize.radius(NeriRadiusRole.full),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: _gap,
        children: [leading, Text(label)],
      ),
    );
  }
}

Size mentionChipSize({
  required String label,
  required double leadingSize,
  required TextStyle style,
  required TextScaler textScaler,
  required TextDirection textDirection,
}) {
  final painter = TextPainter(
    text: TextSpan(text: label, style: style),
    textDirection: textDirection,
    textScaler: textScaler,
  )..layout();

  final size = Size(
    _padding * 2 + leadingSize + _gap + painter.width,
    max(leadingSize, painter.height),
  );
  painter.dispose();

  return size;
}
