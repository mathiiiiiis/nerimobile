import 'package:flutter/painting.dart';

const neriFontFamily = 'GoogleSansFlex';

/// Covers missing glyphs, static fallbacks follow fontWeight
const neriFontFallback = <String>[
  'Roboto',
  'Noto Sans',
  'Segoe UI',
  'Noto Sans JP',
  'Hiragino Sans',
  'PingFang SC',
  'Noto Sans KR',
  'Apple SD Gothic Neo',
];

const neriWeightRange = (min: 1.0, max: 1000.0);
const neriOpticalSizeRange = (min: 6.0, max: 144.0);
const neriRoundnessRange = (min: 0.0, max: 100.0);
const neriGradeRange = (min: 0.0, max: 100.0);
const neriSlantRange = (min: -10.0, max: 0.0);

List<FontVariation> neriFontVariation({
  required double weight,
  required double opticalSize,
  double roundness = 0,
  double grade = 0,
  double slant = 0,
}) => [
  FontVariation('wght', weight.clamp(neriWeightRange.min, neriWeightRange.max)),
  FontVariation(
    'opsz',
    opticalSize.clamp(neriOpticalSizeRange.min, neriOpticalSizeRange.max),
  ),
  FontVariation(
    'ROND',
    roundness.clamp(neriRoundnessRange.min, neriRoundnessRange.max),
  ),
  FontVariation('GRAD', grade.clamp(neriGradeRange.min, neriGradeRange.max)),
  FontVariation('slnt', slant.clamp(neriSlantRange.min, neriSlantRange.max)),
];

FontWeight nearestFontWeight(double weight) =>
    FontWeight.values[((weight / 100).round() - 1).clamp(0, 8)];
