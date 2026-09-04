import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:nerimobile/theme/typography/fonts.dart';

enum NeriTextRole {
  titleLarge,
  headlineSmall,
  bodyLarge,
  bodyMedium,
  bodySmall,
  labelLarge,
  labelSmall,
}

class TextRoleSpec {
  const TextRoleSpec({
    required this.size,
    required this.weight,
    this.height,
    this.letterSpacing,
  });

  final double size;
  final double weight;
  final double? height;
  final double? letterSpacing;
}

const _defaults = <NeriTextRole, TextRoleSpec>{
  NeriTextRole.titleLarge: TextRoleSpec(size: 22, weight: 500, height: 1.25),
  NeriTextRole.headlineSmall: TextRoleSpec(size: 18, weight: 600, height: 1.3),
  NeriTextRole.bodyLarge: TextRoleSpec(size: 16, weight: 400, height: 1.4),
  NeriTextRole.bodyMedium: TextRoleSpec(size: 15, weight: 400, height: 1.45),
  NeriTextRole.bodySmall: TextRoleSpec(size: 13, weight: 400, height: 1.4),
  NeriTextRole.labelLarge: TextRoleSpec(size: 14, weight: 500, height: 1.2),
  NeriTextRole.labelSmall: TextRoleSpec(size: 11, weight: 400, height: 1.2),
};

class TypographySpec {
  const TypographySpec({
    required this.id,
    required this.name,
    this.family = neriFontFamily,
    this.scale = 1,
    this.roundness = 0,
    this.grade = 0,
    this.roles = const {},
  });

  final String id;
  final String name;
  final String family;
  final double scale;
  final double roundness;
  final double grade;
  final Map<NeriTextRole, TextRoleSpec> roles;
}

const defaultTypography = TypographySpec(id: 'nerimobile', name: 'Nerimobile');

class TypographyOverrides {
  const TypographyOverrides({
    this.family,
    this.scale,
    this.roundness,
    this.grade,
    this.roles = const {},
  });

  final String? family;
  final double? scale;
  final double? roundness;
  final double? grade;
  final Map<NeriTextRole, TextRoleSpec> roles;
}

class TypographyResolver {
  TypographyResolver({
    required this.spec,
    this.overrides = const TypographyOverrides(),
  });

  final TypographySpec spec;
  final TypographyOverrides overrides;

  Map<NeriTextRole, TextStyle> resolveAll() => Map.unmodifiable({
    for (final role in NeriTextRole.values) role: resolve(role),
  });

  TextStyle resolve(NeriTextRole role) {
    final roleSpec =
        overrides.roles[role] ?? spec.roles[role] ?? _defaults[role]!;
    final size = roleSpec.size * (overrides.scale ?? spec.scale);

    return TextStyle(
      fontFamily: overrides.family ?? spec.family,
      fontFamilyFallback: neriFontFallback,
      fontSize: size,
      height: roleSpec.height,
      letterSpacing: roleSpec.letterSpacing,
      fontWeight: nearestFontWeight(roleSpec.weight),
      fontVariations: neriFontVariation(
        weight: roleSpec.weight,
        opticalSize: size,
        roundness: overrides.roundness ?? spec.roundness,
        grade: overrides.grade ?? spec.grade,
      ),
    );
  }
}

class NeriTypography extends ThemeExtension<NeriTypography> {
  const NeriTypography(this.styles);

  final Map<NeriTextRole, TextStyle> styles;

  TextStyle operator [](NeriTextRole role) => styles[role] ?? const TextStyle();

  @override
  NeriTypography copyWith({Map<NeriTextRole, TextStyle>? styles}) =>
      NeriTypography(styles ?? this.styles);

  @override
  NeriTypography lerp(NeriTypography? other, double t) {
    if (other == null) return this;
    return NeriTypography({
      for (final role in NeriTextRole.values)
        role: TextStyle.lerp(this[role], other[role], t)!,
    });
  }

  @override
  bool operator ==(Object other) =>
      other is NeriTypography && mapEquals(styles, other.styles);

  @override
  int get hashCode => Object.hashAll(styles.values);
}
