import 'package:flutter/painting.dart';

sealed class ColorSpec {
  const ColorSpec();
}

final class LiteralColor extends ColorSpec {
  const LiteralColor(this.color);

  final Color color;
}

final class ColorReference extends ColorSpec {
  const ColorReference(this.key);

  final String key;
}

ColorSpec? parseCssColor(String raw) {
  final input = raw.trim();
  if (input.isEmpty) return null;

  final reference = _referencePattern.firstMatch(input);
  if (reference != null) return ColorReference(reference.group(1)!);

  final named = _namedColors[input.toLowerCase()];
  if (named != null) return LiteralColor(named);

  if (input.startsWith('#')) {
    final color = _parseHex(input.substring(1));
    return color == null ? null : LiteralColor(color);
  }

  final function = _functionPattern.firstMatch(input);
  if (function == null) return null;

  final arguments = _splitArguments(function.group(2)!);
  if (arguments == null) return null;

  final color = switch (function.group(1)!.toLowerCase()) {
    'rgb' || 'rgba' => _parseRgb(arguments),
    'hsl' || 'hsla' => _parseHsl(arguments),
    _ => null,
  };
  return color == null ? null : LiteralColor(color);
}

final _referencePattern = RegExp(r'^var\(\s*--([^,)\s]+)');
final _functionPattern = RegExp(r'^([a-z]+)\((.*)\)$', caseSensitive: false);
final _whitespacePattern = RegExp(r'\s+');

const _namedColors = <String, Color>{
  'transparent': Color(0x00000000),
  'black': Color(0xFF000000),
  'white': Color(0xFFFFFFFF),
  'red': Color(0xFFFF0000),
  'green': Color(0xFF008000),
  'blue': Color(0xFF0000FF),
  'gray': Color(0xFF808080),
  'grey': Color(0xFF808080),
  'orange': Color(0xFFFFA500),
  'yellow': Color(0xFFFFAF00),
  'purple': Color(0xFF800080),
  'pink': Color(0xFFFFC0CB),
};

typedef _Arguments = ({List<String> parts, String? alpha});

Color? _parseHex(String raw) {
  var hex = raw;
  if (hex.length == 3 || hex.length == 4) {
    hex = hex.split('').map((digit) => '$digit$digit').join();
  }
  if (hex.length == 6) {
    hex = 'FF$hex';
  } else if (hex.length == 8) {
    hex = hex.substring(6) + hex.substring(0, 6);
  } else {
    return null;
  }
  final value = int.tryParse(hex, radix: 16);
  return value == null ? null : Color(value);
}

_Arguments? _splitArguments(String raw) {
  final normalised = raw.replaceAll(',', ' ');
  final separator = normalised.indexOf('/');
  final head = separator == -1
      ? normalised
      : normalised.substring(0, separator);
  final tail = separator == -1 ? null : normalised.substring(separator + 1);

  final parts = head
      .trim()
      .split(_whitespacePattern)
      .where((part) => part.isNotEmpty)
      .toList();

  if (tail != null) {
    final alpha = tail.trim();
    if (parts.length != 3 || alpha.isEmpty) return null;
    return (parts: parts, alpha: alpha);
  }
  if (parts.length == 4) {
    return (parts: parts.sublist(0, 3), alpha: parts[3]);
  }
  if (parts.length != 3) return null;
  return (parts: parts, alpha: null);
}

Color? _parseRgb(_Arguments arguments) {
  final channels = <double>[];
  for (final part in arguments.parts) {
    final value = _parseNumber(part, scale: 255);
    if (value == null) return null;
    channels.add((value / 255).clamp(0.0, 1.0));
  }

  final alpha = _parseAlpha(arguments.alpha);
  if (alpha == null) return null;

  return Color.from(
    alpha: alpha,
    red: channels[0],
    green: channels[1],
    blue: channels[2],
  );
}

Color? _parseHsl(_Arguments arguments) {
  final hue = _parseAngle(arguments.parts[0]);
  final saturation = _parseNumber(arguments.parts[1], scale: 1);
  final lightness = _parseNumber(arguments.parts[2], scale: 1);
  final alpha = _parseAlpha(arguments.alpha);
  if (hue == null || saturation == null || lightness == null || alpha == null) {
    return null;
  }

  return HSLColor.fromAHSL(
    alpha,
    hue,
    saturation.clamp(0.0, 1.0),
    lightness.clamp(0.0, 1.0),
  ).toColor();
}

double? _parseNumber(String raw, {required double scale}) {
  final trimmed = raw.trim();
  if (trimmed.endsWith('%')) {
    final percent = double.tryParse(
      trimmed.substring(0, trimmed.length - 1).trim(),
    );
    return percent == null ? null : percent / 100 * scale;
  }
  return double.tryParse(trimmed);
}

double? _parseAlpha(String? raw) {
  if (raw == null) return 1;
  final value = _parseNumber(raw, scale: 1);
  return value?.clamp(0.0, 1.0);
}

double? _parseAngle(String raw) {
  var trimmed = raw.trim().toLowerCase();
  if (trimmed.endsWith('deg')) {
    trimmed = trimmed.substring(0, trimmed.length - 3);
  }
  final value = double.tryParse(trimmed);
  return value == null ? null : value % 360;
}
