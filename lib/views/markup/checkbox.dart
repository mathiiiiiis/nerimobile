import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:nerimobile/theme/colors/derive.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/border.dart';
import 'package:nerimobile/theme/sizing/radius.dart';

const _tickScale = 0.8;
const _tickWeight = 700.0;

class MarkupCheckbox extends StatelessWidget {
  const MarkupCheckbox({super.key, required this.checked, required this.size});

  final bool checked;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final accent = colors[NeriToken.primary];

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: checked ? accent : Colors.transparent,
        borderRadius: sizing.rounded(NeriRadiusRole.sm),
        border: checked
            ? null
            : Border.all(
                color: colors[NeriToken.textTertiary],
                width: sizing.border(NeriBorderRole.thin),
              ),
      ),
      child: checked
          ? Icon(
              Symbols.check_rounded,
              size: size * _tickScale,
              weight: _tickWeight,
              color: onColor(accent),
            )
          : null,
    );
  }
}
