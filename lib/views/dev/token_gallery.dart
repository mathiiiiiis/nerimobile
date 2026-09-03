import 'package:flutter/material.dart';

import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/theme_spec.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/presets/presets.dart';
import 'package:nerimobile/theme/typography/fonts.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';

enum _Tab { colors, type }

class TokenGallery extends StatefulWidget {
  const TokenGallery({super.key});

  @override
  State<TokenGallery> createState() => _TokenGalleryState();
}

class _TokenGalleryState extends State<TokenGallery> {
  String _presetId = defaultPresetId;
  _Tab _tab = _Tab.colors;
  double _scale = 1;
  double _roundness = 0;
  double _grade = 0;

  @override
  Widget build(BuildContext context) {
    final spec = presetById(_presetId);

    return Theme(
      data: buildNeriTheme(
        spec: spec,
        typographyOverrides: TypographyOverrides(
          scale: _scale,
          roundness: _roundness,
          grade: _grade,
        ),
      ),
      child: Builder(
        builder: (context) => ColoredBox(
          color: context.neri[NeriToken.background],
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(
                  spec: spec,
                  tab: _tab,
                  onPreset: (id) => setState(() => _presetId = id),
                  onTab: (tab) => setState(() => _tab = tab),
                ),
                Expanded(
                  child: switch (_tab) {
                    _Tab.colors => const _ColorList(),
                    _Tab.type => _TypeList(
                      scale: _scale,
                      roundness: _roundness,
                      grade: _grade,
                      onScale: (v) => setState(() => _scale = v),
                      onRoundness: (v) => setState(() => _roundness = v),
                      onGrade: (v) => setState(() => _grade = v),
                    ),
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.spec,
    required this.tab,
    required this.onPreset,
    required this.onTab,
  });

  final ThemeSpec spec;
  final _Tab tab;
  final ValueChanged<String> onPreset;
  final ValueChanged<_Tab> onTab;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final entry in builtInPresets.entries)
                _Chip(
                  label: entry.value.name,
                  selected: entry.key == spec.id,
                  onTap: () => onPreset(entry.key),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final value in _Tab.values) ...[
                _Chip(
                  label: value.name,
                  selected: value == tab,
                  onTap: () => onTab(value),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? colors[NeriToken.primary]
              : colors[NeriToken.drawerItemBackground],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: context.neriText[NeriTextRole.labelLarge].copyWith(
            color: selected
                ? colors[NeriToken.background]
                : colors[NeriToken.drawerItemText],
          ),
        ),
      ),
    );
  }
}

class _ColorList extends StatelessWidget {
  const _ColorList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        for (final category in ThemeCategory.values) ...[
          _SectionLabel(label: category.name),
          for (final token in NeriToken.values)
            if (token.category == category) _TokenRow(token: token),
        ],
      ],
    );
  }
}

class _TypeList extends StatelessWidget {
  const _TypeList({
    required this.scale,
    required this.roundness,
    required this.grade,
    required this.onScale,
    required this.onRoundness,
    required this.onGrade,
  });

  final double scale;
  final double roundness;
  final double grade;
  final ValueChanged<double> onScale;
  final ValueChanged<double> onRoundness;
  final ValueChanged<double> onGrade;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final type = context.neriText;

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        _SectionLabel(label: 'axes'),
        _AxisSlider(
          label: 'scale',
          value: scale,
          min: 0.85,
          max: 1.3,
          onChanged: onScale,
        ),
        _AxisSlider(
          label: 'ROND',
          value: roundness,
          min: neriRoundnessRange.min,
          max: neriRoundnessRange.max,
          onChanged: onRoundness,
        ),
        _AxisSlider(
          label: 'GRAD',
          value: grade,
          min: neriGradeRange.min,
          max: neriGradeRange.max,
          onChanged: onGrade,
        ),
        _SectionLabel(label: 'roles'),
        for (final role in NeriTextRole.values) _RoleSample(role: role),
        _SectionLabel(label: 'slant (markup italics)'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(
            'Say hello, Nerimobile!',
            style: _slanted(
              type[NeriTextRole.bodyLarge],
            ).copyWith(color: colors[NeriToken.text]),
          ),
        ),
        _SectionLabel(label: 'fallback (not google sans flex)'),
        for (final sample in const [
          'Привет, Неримобайл!',
          'Γεια σου, Νερίμομπαϊλ!',
          'こんにちは、ネリモバイル！',
          '안녕, 네리모바일!',
        ])
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              sample,
              style: type[NeriTextRole.bodyLarge].copyWith(
                color: colors[NeriToken.text],
              ),
            ),
          ),
      ],
    );
  }
}

class _AxisSlider extends StatelessWidget {
  const _AxisSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(
              label,
              style: context.neriText[NeriTextRole.labelSmall].copyWith(
                color: colors[NeriToken.textTertiary],
              ),
            ),
          ),
          Expanded(
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 44,
            child: Text(
              value.toStringAsFixed(2),
              textAlign: TextAlign.end,
              style: context.neriText[NeriTextRole.labelSmall].copyWith(
                color: colors[NeriToken.textTertiary],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleSample extends StatelessWidget {
  const _RoleSample({required this.role});

  final NeriTextRole role;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final style = context.neriText[role];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${role.name}   ${style.fontSize?.toStringAsFixed(1)}   '
            'wght ${_axis(style, 'wght')?.toStringAsFixed(0)}  '
            'opsz ${_axis(style, 'opsz')?.toStringAsFixed(1)}',
            style: context.neriText[NeriTextRole.labelSmall].copyWith(
              color: colors[NeriToken.textTertiary],
            ),
          ),
          Text(
            'Go touch some grass, you idiot 0123',
            style: style.copyWith(color: colors[NeriToken.text]),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Text(
        label,
        style: context.neriText[NeriTextRole.labelSmall].copyWith(
          color: context.neri[NeriToken.textTertiary],
        ),
      ),
    );
  }
}

class _TokenRow extends StatelessWidget {
  const _TokenRow({required this.token});

  final NeriToken token;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final color = colors[token];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          _Swatch(color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              token.name,
              style: context.neriText[NeriTextRole.bodySmall].copyWith(
                color: colors[NeriToken.text],
              ),
            ),
          ),
          Text(
            _describe(color),
            style: context.neriText[NeriTextRole.labelSmall].copyWith(
              color: colors[NeriToken.textTertiary],
            ),
          ),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 72,
        height: 32,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Row(
              children: [
                Expanded(
                  child: ColoredBox(color: colors[NeriToken.background]),
                ),
                Expanded(child: ColoredBox(color: colors[NeriToken.pane])),
                Expanded(child: ColoredBox(color: colors[NeriToken.card])),
              ],
            ),
            ColoredBox(color: color),
          ],
        ),
      ),
    );
  }
}

TextStyle _slanted(TextStyle style) => style.copyWith(
  fontVariations: [
    for (final variation in style.fontVariations ?? const <FontVariation>[])
      if (variation.axis == 'slnt')
        FontVariation('slnt', neriSlantRange.min)
      else
        variation,
  ],
);

double? _axis(TextStyle style, String axis) {
  for (final variation in style.fontVariations ?? const <FontVariation>[]) {
    if (variation.axis == axis) return variation.value;
  }
  return null;
}

String _describe(Color color) {
  final rgb = (color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0');
  final alpha = (color.a * 100).round();
  return alpha == 100 ? '#$rgb' : '#$rgb $alpha%';
}
