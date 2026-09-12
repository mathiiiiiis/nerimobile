import 'package:flutter/material.dart';
import 'dart:math';

Color hexToColor(String hex) {
  final h = hex.replaceAll('#', '');
  return Color(int.parse('FF$h', radix: 16));
}

({LinearGradient? gradient, List<Color>? colors, String? error})
convertShorthandToLinearGradient(String shorthand) {
  final parts = shorthand.trim().split(RegExp(r'\s+'));

  if (parts.length < 3 || parts.length > 5) {
    return (
      gradient: null,
      colors: null,
      error: 'Invalid format (must represent 2-4 colors)',
    );
  }

  final startMatch = RegExp(
    r'^lg(\d+)(#[a-f0-9]{3,6})$',
    caseSensitive: false,
  ).firstMatch(parts[0]);
  if (startMatch == null) {
    return (
      gradient: null,
      colors: null,
      error: 'Invalid start format (e.g., lg0#ffffff)',
    );
  }

  final degree = double.parse(startMatch.group(1)!);
  final hexes = <String>[startMatch.group(2)!];
  final stops = <double>[];

  for (int i = 1; i < parts.length - 1; i++) {
    final middleMatch = RegExp(
      r'^(\d+)(#[a-f0-9]{3,6})$',
      caseSensitive: false,
    ).firstMatch(parts[i]);
    if (middleMatch == null) {
      return (
        gradient: null,
        colors: null,
        error: 'Invalid middle format at part ${i + 1}',
      );
    }
    stops.add(double.parse(middleMatch.group(1)!) / 100);
    hexes.add(middleMatch.group(2)!);
  }

  final endMatch = RegExp(r'^(\d+)$').firstMatch(parts.last);
  if (endMatch == null) {
    return (
      gradient: null,
      colors: null,
      error: 'Invalid end format (must be a number)',
    );
  }
  stops.add(double.parse(endMatch.group(1)!) / 100);

  final colors = hexes.map(parseHexColor).toList();

  return (
    gradient: _gradientFromDegree(degree, colors, stops),
    colors: colors,
    error: null,
  );
}

Color parseHexColor(String hex) {
  switch (hex.toLowerCase()) {
    case 'white':
      return Colors.white;
    case 'black':
      return Colors.black;
    case 'red':
      return Colors.red;
  }

  var h = hex.replaceFirst('#', '');
  if (h.length == 3 || h.length == 4) {
    h = h.split('').map((c) => '$c$c').join();
  }
  //css order ≠ flutter order
  if (h.length == 8) h = '${h.substring(6)}${h.substring(0, 6)}';
  return Color(int.parse(h.length == 6 ? 'FF$h' : h, radix: 16));
}

const _hex = r'#(?:[a-fA-F0-9]{3,4}|[a-fA-F0-9]{6}|[a-fA-F0-9]{8})';
final _colorExprPattern = RegExp(
  '^($_hex(?:-$_hex)+)'
  r'\s+(.*)$',
);

({List<Color> colors, String text})? parseColorExpr(String expr) {
  final match = _colorExprPattern.firstMatch(expr.trim());
  if (match == null) return null;

  return (
    colors: match.group(1)!.split('-').map(parseHexColor).toList(),
    text: match.group(2)!,
  );
}

LinearGradient _gradientFromDegree(
  double degree,
  List<Color> colors,
  List<double> stops,
) {
  final rad = (degree - 90) * (3.141592653589793 / 180);
  final x = cos(rad);
  final y = sin(rad);
  return LinearGradient(
    begin: Alignment(-x, -y),
    end: Alignment(x, y),
    colors: colors,
    stops: stops,
  );
}

Widget buildColoredName(
  String text, {
  String? hexColor,
  TextStyle? style,
  TextOverflow? overflow,
  int? maxLines,
}) {
  final effectiveStyle = (style ?? const TextStyle()).copyWith(
    color: hexColor != null && !hexColor.startsWith('lg')
        ? parseHexColor(hexColor)
        : null,
  );

  if (hexColor != null && hexColor.startsWith('lg')) {
    final result = convertShorthandToLinearGradient(hexColor);
    if (result.gradient != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: ShaderMask(
              shaderCallback: (bounds) => result.gradient!.createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: Text(
                text,
                style: effectiveStyle.copyWith(color: Colors.white),
                overflow: overflow,
                maxLines: maxLines,
              ),
            ),
          ),
        ],
      );
    }
  }

  return Text(
    text,
    style: effectiveStyle,
    overflow: overflow,
    maxLines: maxLines,
  );
}
