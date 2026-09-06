import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nerimobile/models/message.dart';
import 'package:nerimobile/stores/user/user_store.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';
import 'package:nerimobile/views/avatar.dart';
import 'package:nerimobile/views/markup.dart';

const _groupWindow = Duration(minutes: 5);
const _messageGap = NeriSpacingRole.md;
const _groupGap = NeriSpacingRole.xs;

class MessageRow extends ConsumerWidget {
  const MessageRow({super.key, required this.message, this.before});

  final Message message;
  final Message? before;

  bool get _isSystem => message.type != MessageType.content;

  bool get _compact {
    final previous = before;
    if (previous == null || _isSystem) return false;
    if (message.replyMessages.isNotEmpty) return false;
    if (previous.type != MessageType.content) return false;
    if (previous.createdBy.id != message.createdBy.id) return false;

    final gap = message.createdAt - previous.createdAt;
    return gap < _groupWindow.inMilliseconds;
  }

  bool get _newDay {
    final previous = before;
    if (previous == null) return true;

    final a = DateTime.fromMillisecondsSinceEpoch(previous.createdAt);
    final b = DateTime.fromMillisecondsSinceEpoch(message.createdAt);
    return b.year != a.year || b.month != a.month || b.day != a.day;
  }

  bool _mentionsMe(String? userId) {
    if (userId == null) return false;
    if (message.mentions.any((u) => u.id == userId)) return true;
    return message.replyMessages.any(
      (r) => r.replyToMessage?.createdBy.id == userId,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sizing = context.neriSize;
    final gap = before == null
        ? 0.0
        : sizing.space(_compact ? _groupGap : _messageGap);
    final mentioned = _mentionsMe(ref.watch(currentUserProvider)?.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_newDay) _DayDivider(timestamp: message.createdAt),
        if (!_newDay) SizedBox(height: gap),
        _Highlight(
          mentioned: mentioned,
          gap: _newDay ? 0.0 : gap,
          child: _isSystem
              ? _SystemMessages(message: message)
              : _compact
              ? _CompactMessage(message: message)
              : _FullMessage(message: message),
        ),
      ],
    );
  }
}

class _Highlight extends StatelessWidget {
  const _Highlight({
    required this.mentioned,
    required this.gap,
    required this.child,
  });

  final bool mentioned;
  final double gap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!mentioned) return child;

    final colors = context.neri;
    final sizing = context.neriSize;

    return Container(
      padding: EdgeInsets.symmetric(vertical: sizing.space(NeriSpacingRole.xs)),
      decoration: BoxDecoration(
        color: colors[NeriToken.messageMentionBackground],
      ),
      child: child,
    );
  }
}

class _FullMessage extends StatelessWidget {
  const _FullMessage({required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: sizing.space(NeriSpacingRole.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: sizing.space(NeriSpacingRole.md),
        children: [
          Avatar(
            user: message.createdBy,
            size: sizing.dimen(NeriDimen.avatarSm),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: sizing.space(NeriSpacingRole.sm),
                  children: [
                    Flexible(
                      child: Text(
                        message.createdBy.username,
                        overflow: TextOverflow.ellipsis,
                        style: context.neriText[NeriTextRole.labelLarge]
                            .copyWith(color: colors[NeriToken.text]),
                      ),
                    ),
                    Text(
                      formatTime(message.createdAt),
                      style: context.neriText[NeriTextRole.labelSmall].copyWith(
                        color: colors[NeriToken.textPlaceholder],
                      ),
                    ),
                  ],
                ),
                MarkupView(rawText: message.content, message: message),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactMessage extends StatelessWidget {
  const _CompactMessage({required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    final sizing = context.neriSize;

    return Padding(
      padding: EdgeInsets.only(
        left:
            sizing.space(NeriSpacingRole.md) +
            sizing.dimen(NeriDimen.avatarSm) +
            sizing.space(NeriSpacingRole.md),
        right: sizing.space(NeriSpacingRole.md),
      ),
      child: MarkupView(rawText: message.content, message: message),
    );
  }
}

class _SystemMessages extends StatelessWidget {
  const _SystemMessages({required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: sizing.space(NeriSpacingRole.md),
      ),
      child: Text(
        '${message.createdBy.username} ${_systemText(message.type)}',
        style: context.neriText[NeriTextRole.bodySmall].copyWith(
          color: colors[NeriToken.textPlaceholder],
        ),
      ),
    );
  }
}

class _DayDivider extends StatelessWidget {
  const _DayDivider({required this.timestamp});

  final int timestamp;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: sizing.space(NeriSpacingRole.md),
        vertical: sizing.space(NeriSpacingRole.md),
      ),
      child: Row(
        spacing: sizing.space(NeriSpacingRole.md),
        children: [
          Expanded(child: Divider(color: colors[NeriToken.divider])),
          Text(
            formatDay(timestamp),
            style: context.neriText[NeriTextRole.labelSmall].copyWith(
              color: colors[NeriToken.textPlaceholder],
            ),
          ),
          Expanded(child: Divider(color: colors[NeriToken.divider])),
        ],
      ),
    );
  }
}

String _systemText(MessageType type) => switch (type) {
  MessageType.joinServer => 'joined the server', //TODO: add l10n
  MessageType.leaveServer => 'left the server', //TODO: add l10n
  MessageType.kickUser => 'was kicked', //TODO: add l10n
  MessageType.banUser => 'was banned', //TODO: add l10n
  MessageType.callStarted => 'started a call', //TODO: add l10n
  MessageType.bumpServer => 'bumped the server', //TODO: add l10n
  MessageType.pinnedMessage => 'pinned a message', //TODO: add l10n
  MessageType.content => '',
};

String formatTime(int timestamp) {
  final time = DateTime.fromMillisecondsSinceEpoch(timestamp);
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String formatDay(int timestamp) {
  final day = DateTime.fromMillisecondsSinceEpoch(timestamp);
  return '${day.day.toString().padLeft(2, '0')}.'
      '${day.month.toString().padLeft(2, '0')}.${day.year}';
}
