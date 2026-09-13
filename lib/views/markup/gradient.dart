import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class GradientSpan extends TextSpan {
  const GradientSpan({
    required this.colors,
    required String super.text,
    super.style,
    super.recognizer,
  });

  final List<Color> colors;
}

List<ui.Shader> gradientShaders(InlineSpan root, TextPainter painter) {
  final shaders = <ui.Shader>[];
  var offset = 0;

  root.visitChildren((span) {
    if (span is GradientSpan) {
      final length = span.text!.length;
      final boxes = painter.getBoxesForSelection(
        TextSelection(baseOffset: offset, extentOffset: offset + length),
      );
      shaders.add(
        LinearGradient(
          colors: span.colors,
        ).createShader(_bounds(boxes, painter)),
      );
      offset += length;
      return true;
    }

    offset += span is TextSpan ? span.text?.length ?? 0 : 1;
    return true;
  });

  return shaders;
}

Rect _bounds(List<TextBox> boxes, TextPainter painter) {
  if (boxes.isEmpty) return Rect.fromLTWH(0, 0, painter.width, painter.height);

  return boxes
      .map((box) => box.toRect())
      .reduce((a, b) => a.expandToInclude(b));
}
