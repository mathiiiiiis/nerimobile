import 'package:flutter/painting.dart';

import 'package:nerimobile/theme/colors/css_colors.dart';
import 'package:nerimobile/theme/core/registry.dart';
import 'package:nerimobile/theme/core/theme_spec.dart';
import 'package:nerimobile/theme/core/token.dart';

class ThemeResolver {
  ThemeResolver({required this.spec, this.overrides = const {}});

  final ThemeSpec spec;
  final Map<NeriToken, String> overrides;

  final Map<NeriToken, Color> _cache = {};
  final Set<NeriToken> _pending = {};

  Map<NeriToken, Color> resolveAll() => Map.unmodifiable({
    for (final token in NeriToken.values) token: resolve(token),
  });

  Color resolve(NeriToken token) {
    final cached = _cache[token];
    if (cached != null) return cached;

    if (!_pending.add(token)) {
      assert(false, 'cyclic drivation for $token');
      return const Color(0x00000000);
    }

    final color = _fromSpec(token) ?? deriveToken(token, resolve);
    _pending.remove(token);
    _cache[token] = color;
    return color;
  }

  Color? _fromSpec(NeriToken token) {
    final value = overrides[token] ?? spec.values[token];
    return value == null ? null : _evaluate(value, {});
  }

  Color? _evaluate(String value, Set<String> seen) =>
      switch (parseCssColor(value)) {
        LiteralColor(:final color) => color,
        ColorReference(:final key) => _evaluateVariable(key, seen),
        null => null,
      };

  Color? _evaluateVariable(String key, Set<String> seen) {
    //imported theme == untrusted, may define self ref variables
    if (!seen.add(key)) return null;
    final value = spec.variables[key];
    return value == null ? null : _evaluate(value, seen);
  }
}
