import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nerimobile/models/message.dart';
import 'package:nerimobile/stores/server/server_store.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';
import 'package:nerimobile/utils/colors.dart';
import 'package:nerimobile/views/chat/message_list.dart';

const _lineWidth = 2.0;
const _cornerRadius = 8.0;
const _tickWidth = 16.0;
const _contentLeft = 22.0;

class MessageReplies extends StatelessWidget {
  const MessageReplies({super.key, required this.replies});

  final List<ReplyMessage> replies;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final rowHeight = sizing.dimen(NeriDimen.replyHeight);
    final avatar = sizing.dimen(NeriDimen.avatarSm);
    final side = BorderSide(
      color: colors[NeriToken.divider],
      width: _lineWidth,
    );

    return Padding(
      padding: EdgeInsets.only(
        left: avatar / 2 - _lineWidth / 2,
        bottom: sizing.space(NeriSpacingRole.xs),
      ),
      child: Stack(
        children: [
          Positioned(
            top: rowHeight / 2,
            bottom: 0,
            width: _tickWidth,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(left: side, top: side),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(_cornerRadius),
                ),
              ),
            ),
          ),
          for (var index = 1; index < replies.length; index += 1)
            Positioned(
              top: rowHeight * index + rowHeight / 2 - _lineWidth / 2,
              width: _tickWidth,
              height: _lineWidth,
              child: ColoredBox(color: colors[NeriToken.divider]),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final reply in replies)
                SizedBox(
                  height: rowHeight,
                  child: _ReplyTarget(
                    message: reply.replyToMessage,
                    child: Padding(
                      padding: const EdgeInsets.only(left: _contentLeft),
                      child: _ReplyContent(message: reply.replyToMessage),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReplyContent extends ConsumerWidget {
  const _ReplyContent({required this.message});

  final PartialMessage? message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final reply = message;
    final style = context.neriText[NeriTextRole.bodySmall];

    if (reply == null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Message deleted', //TODO: add l10n
          style: style.copyWith(
            color: colors[NeriToken.textPlaceholder],
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    final attachmentOnly =
        reply.content.isEmpty && reply.attachments.isNotEmpty;

    final hexColor = memberTopColor(
      ref.watch(currentServerMembersProvider)?[reply.createdBy.id],
      ref.watch(sortedRolesProvider),
      ref.watch(currentServerDefaultRoleProvider),
    );

    return Row(
      spacing: sizing.space(NeriSpacingRole.xs),
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 200),
          child: Text(
            reply.createdBy.username,
            overflow: TextOverflow.ellipsis,
            style: style.copyWith(color: colors[NeriToken.textSecondary]),
          ),
        ),
        Expanded(
          child: Text(
            attachmentOnly
                ? 'Sent an attachment'
                : reply.content, //TODO: add l10n
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style.copyWith(
              color: hexColor == null
                  ? colors[NeriToken.textPlaceholder]
                  : hexToColor(hexColor),
              fontStyle: attachmentOnly ? FontStyle.italic : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReplyTarget extends StatelessWidget {
  const _ReplyTarget({required this.message, required this.child});

  final PartialMessage? message;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final reply = message;
    if (reply == null) return child;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context
          .findAncestorStateOfType<MessageListState>()
          ?.scrollToMessage(reply.id),
      child: child,
    );
  }
}
