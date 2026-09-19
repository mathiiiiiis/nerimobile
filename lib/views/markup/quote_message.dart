import 'package:flutter/material.dart';

import 'package:nerimobile/models/message.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/border.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';
import 'package:nerimobile/utils/colors.dart';
import 'package:nerimobile/utils/date.dart';
import 'package:nerimobile/views/avatar.dart';
import 'package:nerimobile/views/chat/message/message_list.dart';
import 'package:nerimobile/views/markup/markup.dart';

class QuoteMessageView extends StatelessWidget {
  const QuoteMessageView({super.key, required this.quote});

  final PartialMessage quote;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final text = context.neriText;

    return GestureDetector(
      onTap: () => context
          .findRootAncestorStateOfType<MessageListState>()
          ?.scrollToMessage(quote.id),
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colors[NeriToken.pane],
          borderRadius: sizing.rounded(NeriRadiusRole.md),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              width: sizing.border(NeriBorderRole.thick),
              child: ColoredBox(color: colors[NeriToken.primary]),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                sizing.border(NeriBorderRole.thick) +
                    sizing.space(NeriSpacingRole.sm),
                sizing.space(NeriSpacingRole.sm),
                sizing.space(NeriSpacingRole.sm),
                sizing.space(NeriSpacingRole.sm),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: sizing.space(NeriSpacingRole.xs),
                children: [
                  Row(
                    spacing: sizing.space(NeriSpacingRole.sm),
                    children: [
                      Avatar(
                        size: sizing.dimen(NeriDimen.avatarXs),
                        user: quote.createdBy,
                      ),
                      Text(
                        quote.createdBy.username,
                        style: text[NeriTextRole.bodyMedium].copyWith(
                          color: hexToColor(quote.createdBy.hexColor),
                        ),
                      ),
                      Text(
                        formatTimestamp(quote.createdAt),
                        style: text[NeriTextRole.bodySmall].copyWith(
                          color: colors[NeriToken.textTertiary],
                        ),
                      ),
                    ],
                  ),
                  MarkupView(
                    rawText: quote.content,
                    mentions: quote.mentions,
                    isQuote: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
