import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:nerimobile/theme/colors/derive.dart';
import 'package:nerimobile/theme/core/resolver.dart';
import 'package:nerimobile/theme/core/theme_spec.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/sizing.dart';
import 'package:nerimobile/theme/typography/fonts.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';

class NeriColors extends ThemeExtension<NeriColors> {
  const NeriColors(this.colors);

  final Map<NeriToken, Color> colors;

  Color operator [](NeriToken token) =>
      colors[token] ?? const Color(0xFF000000);

  @override
  NeriColors copyWith({Map<NeriToken, Color>? colors}) =>
      NeriColors(colors ?? this.colors);

  @override
  NeriColors lerp(NeriColors? other, double t) {
    if (other == null) return this;
    return NeriColors({
      for (final token in NeriToken.values)
        token: Color.lerp(this[token], other[token], t)!,
    });
  }

  @override
  bool operator ==(Object other) =>
      other is NeriColors && mapEquals(colors, other.colors);

  @override
  int get hashCode => Object.hashAll(colors.values);
}

extension NeriTheme on BuildContext {
  NeriColors get neri => Theme.of(this).extension<NeriColors>()!;
  NeriTypography get neriText => Theme.of(this).extension<NeriTypography>()!;
  NeriSizing get neriSize => Theme.of(this).extension<NeriSizing>()!;
}

ThemeData buildNeriTheme({
  required ThemeSpec spec,
  Map<NeriToken, String> overrides = const {},
  TypographySpec typography = defaultTypography,
  TypographyOverrides typographyOverrides = const TypographyOverrides(),
  SizingSpec sizing = defaultSizing,
  SizingOverrides sizingOverrides = const SizingOverrides(),
}) {
  final colors = NeriColors(
    ThemeResolver(spec: spec, overrides: overrides).resolveAll(),
  );
  final text = NeriTypography(
    TypographyResolver(
      spec: typography,
      overrides: typographyOverrides,
    ).resolveAll(),
  );
  final size = SizingResolver(
    spec: sizing,
    overrides: sizingOverrides,
  ).resolve();
  final brightness = _brightnessOf(colors[NeriToken.background]);

  return ThemeData(
    brightness: brightness,
    fontFamily: typographyOverrides.family ?? typography.family,
    fontFamilyFallback: neriFontFallback,
    scaffoldBackgroundColor: colors[NeriToken.background],
    canvasColor: colors[NeriToken.background],
    dividerColor: colors[NeriToken.divider],
    extensions: [colors, text, size],
    textTheme: _textTheme(text, colors[NeriToken.text]),
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: colors[NeriToken.primary],
      onPrimary: onColor(colors[NeriToken.primary]),
      secondary: colors[NeriToken.primary],
      onSecondary: onColor(colors[NeriToken.primary]),
      error: colors[NeriToken.alert],
      onError: onColor(colors[NeriToken.alert]),
      surface: colors[NeriToken.pane],
      onSurface: colors[NeriToken.text],
    ),
  );
}

TextTheme _textTheme(NeriTypography text, Color color) => TextTheme(
  titleLarge: text[NeriTextRole.titleLarge],
  headlineSmall: text[NeriTextRole.headlineSmall],
  bodyLarge: text[NeriTextRole.bodyLarge],
  bodyMedium: text[NeriTextRole.bodyMedium],
  bodySmall: text[NeriTextRole.bodySmall],
  labelLarge: text[NeriTextRole.labelLarge],
  labelSmall: text[NeriTextRole.labelSmall],
).apply(bodyColor: color, displayColor: color);

Brightness _brightnessOf(Color color) =>
    color.computeLuminance() > 0.45 ? Brightness.light : Brightness.dark;
