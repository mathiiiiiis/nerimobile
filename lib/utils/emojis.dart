import 'package:nerimobile/config.dart';

const _u200d = '\u200D';
final _uFE0Fg = RegExp('\uFE0F');

String unicodeToTwemojiUrl(String unicode) {
  final input = unicode.contains(_u200d)
      ? unicode
      : unicode.replaceAll(_uFE0Fg, '');
  final codePoint = toCodePoint(input);
  return '$twemojiUrl$codePoint.svg';
}

String toCodePoint(String unicodeSurrogates, {String separator = '-'}) {
  final codePoints = <String>[];
  int lead = 0;
  int index = 0;

  while (index < unicodeSurrogates.length) {
    final current = unicodeSurrogates.codeUnitAt(index++);

    if (lead != 0) {
      final combined = 0x10000 + ((lead - 0xD800) << 10) + (current - 0xDC00);
      codePoints.add(combined.toRadixString(16));
      lead = 0;
    } else if (current >= 0xD800 && current <= 0xDBFF) {
      lead = current;
    } else {
      codePoints.add(current.toRadixString(16));
    }
  }

  return codePoints.join(separator);
}
