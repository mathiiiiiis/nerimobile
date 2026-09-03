import 'package:flutter/material.dart';

import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/theme_spec.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/presets/presets.dart';

class TokenGallery extends StatefulWidget {
  const TokenGallery({super.key});

  @override
  State<TokenGallery> createState() => _TokenGalleryState();
}

class _TokenGalleryState extends State<TokenGallery> {
  String _presetId = defaultPresetId;

  @override
  Widget build(BuildContext context) {
    final spec = presetById(_presetId);

    return Theme(
      data: buildNeriTheme(spec: spec),
      child: Builder(
        builder: (context) => ColoredBox(
          color: context.neri[NeriToken.background],
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(spec: spec, onSelect: _select),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 32),
                    children: [
                      for (final category in ThemeCategory.values) ...[
                        _CategoryLabel(category: category),
                        for (final token in NeriToken.values)
                          if (token.category == category)
                            _TokenRow(token: token),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _select(String id) => setState(() => _presetId = id);
}

class _Header extends StatelessWidget {
  const _Header({required this.spec, required this.onSelect});

  final ThemeSpec spec;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Google Sans Flex   AaBbGg 0123',
            style: TextStyle(color: colors[NeriToken.text], fontSize: 18),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final entry in builtInPresets.entries)
                _PresetChip(
                  label: entry.value.name,
                  selected: entry.value.id == spec.id,
                  onTap: () => onSelect(entry.key),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
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
          style: TextStyle(
            color: selected
                ? colors[NeriToken.background]
                : colors[NeriToken.drawerItemText],
          ),
        ),
      ),
    );
  }
}

class _CategoryLabel extends StatelessWidget {
  const _CategoryLabel({required this.category});

  final ThemeCategory category;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Text(
        category.name,
        style: TextStyle(
          color: context.neri[NeriToken.textTertiary],
          fontSize: 12,
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
              style: TextStyle(color: colors[NeriToken.text], fontSize: 14),
            ),
          ),
          Text(
            _describe(color),
            style: TextStyle(
              color: colors[NeriToken.textTertiary],
              fontSize: 12,
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

String _describe(Color color) {
  final rgb = (color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0');
  final alpha = (color.a * 100).round();
  return alpha == 100 ? '#$rgb' : '#$rgb $alpha%';
}
