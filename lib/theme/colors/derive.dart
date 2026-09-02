import 'package:flutter/painting.dart';

Color dim(Color color, double amount) =>
    color.withValues(alpha: color.a * amount.clamp(0.0, 1.0));

Color mix(Color base, Color other, double amount) {
  final t = amount.clamp(0.0, 1.0);
  return Color.from(
    alpha: base.a + (other.a - base.a) * t,
    red: base.r + (other.r - base.r) * t,
    green: base.g + (other.g - base.g) * t,
    blue: base.b + (other.b - base.b) * t,
  );
}

Color lift(Color color, double amount) =>
    mix(color, const Color(0xFFFFFFFF), amount);
