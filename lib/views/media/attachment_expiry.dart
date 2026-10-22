import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';
import 'package:nerimobile/utils/format.dart';

class AttachmentExpiry extends StatelessWidget {
  const AttachmentExpiry({super.key, required this.expireAt});

  final int expireAt;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final expired = DateTime.now().millisecondsSinceEpoch > expireAt;
    final color = expired ? colors[NeriToken.alert] : colors[NeriToken.warn];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Symbols.schedule_rounded,
          size: sizing.dimen(NeriDimen.iconSm) * 0.6,
          color: color,
        ),
        Text(
          formatExpiry(expireAt),
          style: context.neriText[NeriTextRole.labelSmall].copyWith(
            color: color,
          ),
        ),
      ],
    );
  }
}
