import 'package:flutter/material.dart';

const _annotationScale = 0.55;

class RubyText extends StatelessWidget {
  const RubyText({super.key, required this.pairs, required this.style});

  final List<(String text, String annotation)> pairs;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final annotationStyle = style.copyWith(
      fontSize: (style.fontSize ?? 14) * _annotationScale,
    );

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        for (final (text, annotation) in pairs)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(annotation, style: annotationStyle),
              Text(text, style: style),
            ],
          ),
      ],
    );
  }
}
