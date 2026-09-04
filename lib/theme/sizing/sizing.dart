import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';

class SizingSpec {
  const SizingSpec({
    required this.id,
    required this.name,
    this.radiusScale = 1,
    this.radii = const {},
    this.spacing = const {},
    this.dimens = const {},
  });

  final String id;
  final String name;
  final double radiusScale;
  final Map<NeriRadiusRole, double> radii;
  final Map<NeriSpacingRole, double> spacing;
  final Map<NeriDimen, double> dimens;
}

const defaultSizing = SizingSpec(id: 'nerimobile', name: 'Nerimobile');

class SizingOverrides {
  const SizingOverrides({
    this.radiusScale,
    this.radii = const {},
    this.spacing = const {},
    this.dimens = const {},
  });

  final double? radiusScale;
  final Map<NeriRadiusRole, double> radii;
  final Map<NeriSpacingRole, double> spacing;
  final Map<NeriDimen, double> dimens;
}

class SizingResolver {
  SizingResolver({
    required this.spec,
    this.overrides = const SizingOverrides(),
  });

  final SizingSpec spec;
  final SizingOverrides overrides;

  NeriSizing resolve() => NeriSizing(
    radii: {for (final role in NeriRadiusRole.values) role: _radius(role)},
    spacing: {
      for (final role in NeriSpacingRole.values)
        role:
            overrides.spacing[role] ??
            spec.spacing[role] ??
            neriSpacingDefault[role]!,
    },
    dimens: {
      for (final dimen in NeriDimen.values)
        dimen:
            overrides.dimens[dimen] ??
            spec.dimens[dimen] ??
            neriDimentDefaults[dimen]!,
    },
  );

  double _radius(NeriRadiusRole role) {
    final base =
        overrides.radii[role] ?? spec.radii[role] ?? neriRadiusDefaults[role]!;

    //full == pill. scaling down = sqaure off avatars
    if (role == NeriRadiusRole.full) return base;

    final scale = (overrides.radiusScale ?? spec.radiusScale).clamp(
      neriRadiusScaleRange.min,
      neriRadiusScaleRange.max,
    );
    return base * scale;
  }
}

class NeriSizing extends ThemeExtension<NeriSizing> {
  const NeriSizing({
    this.radii = const {},
    this.spacing = const {},
    this.dimens = const {},
  });

  final Map<NeriRadiusRole, double> radii;
  final Map<NeriSpacingRole, double> spacing;
  final Map<NeriDimen, double> dimens;

  double radius(NeriRadiusRole role) => radii[role] ?? 0;

  BorderRadius rounded(NeriRadiusRole role) =>
      BorderRadius.circular(radius(role));

  double space(NeriSpacingRole role) => spacing[role] ?? 0;

  double dimen(NeriDimen value) => dimens[value] ?? 0;

  @override
  NeriSizing copyWith({
    Map<NeriRadiusRole, double>? radii,
    Map<NeriSpacingRole, double>? spacing,
    Map<NeriDimen, double>? dimens,
  }) => NeriSizing(
    radii: radii ?? this.radii,
    spacing: spacing ?? this.spacing,
    dimens: dimens ?? this.dimens,
  );

  @override
  NeriSizing lerp(NeriSizing? other, double t) {
    if (other == null) return this;
    return NeriSizing(
      radii: {
        for (final role in NeriRadiusRole.values)
          role: lerpDouble(radius(role), other.radius(role), t)!,
      },
      spacing: {
        for (final role in NeriSpacingRole.values)
          role: lerpDouble(space(role), other.space(role), t)!,
      },
      dimens: {
        for (final value in NeriDimen.values)
          value: lerpDouble(dimen(value), other.dimen(value), t)!,
      },
    );
  }

  @override
  bool operator ==(Object other) =>
      other is NeriSizing &&
      mapEquals(radii, other.radii) &&
      mapEquals(spacing, other.spacing) &&
      mapEquals(dimens, other.dimens);

  @override
  int get hashCode => Object.hash(
    Object.hashAll(radii.values),
    Object.hashAll(spacing.values),
    Object.hashAll(dimens.values),
  );
}
