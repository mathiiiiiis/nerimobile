import 'package:flutter/material.dart';

import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/border.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';

class BlockquoteView extends StatelessWidget {
  const BlockquoteView({super.key, required this.content});

  final InlineSpan content;

  @override
  Widget build(BuildContext context) {
    final sizing = context.neriSize;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(left: sizing.space(NeriSpacingRole.sm)),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: context.neri[NeriToken.divider],
            width: sizing.border(NeriBorderRole.medium),
          ),
        ),
      ),
      child: Text.rich(content),
    );
  }
}
