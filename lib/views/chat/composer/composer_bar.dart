import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:nerimobile/models/message.dart';
import 'package:nerimobile/stores/composer/composer_store.dart';

import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';
import 'package:nerimobile/views/chat/message/message_replies.dart';
import 'package:nerimobile/views/press_scale.dart';

const _resize = Duration(milliseconds: 150);

class ComposerBar extends ConsumerWidget {
  const ComposerBar({super.key, required this.channelId});

  final String channelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final replyTo = ref.watch(
      composerProvider(channelId).select((c) => c.replyTo),
    );

    return AnimatedSize(
      duration: _resize,
      curve: Curves.easeOut,
      alignment: Alignment.bottomCenter,
      child: replyTo.isEmpty
          ? const SizedBox(width: double.infinity)
          : _ReplyBar(channelId: channelId, replyTo: replyTo),
    );
  }
}

class _ReplyBar extends ConsumerWidget {
  const _ReplyBar({required this.channelId, required this.replyTo});

  final String channelId;
  final List<Message> replyTo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final rowHeight = sizing.dimen(NeriDimen.replyHeight);
    final composer = ref.read(composerProvider(channelId).notifier);
    final mention = ref.watch(
      composerProvider(channelId).select((c) => c.mentionReplies),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        sizing.space(NeriSpacingRole.md),
        0,
        0,
        sizing.space(NeriSpacingRole.xs),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: rowHeight,
            child: Row(
              spacing: sizing.space(NeriSpacingRole.xs),
              children: [
                Icon(
                  Symbols.reply_rounded,
                  size: sizing.dimen(NeriDimen.iconSm),
                  color: colors[NeriToken.textSecondary],
                ),
                Expanded(
                  //TODO: add l10n
                  child: Text(
                    replyTo.length == 1
                        ? 'Replying to'
                        : 'Replying to ${replyTo.length} messages',
                    style: context.neriText[NeriTextRole.bodySmall].copyWith(
                      color: colors[NeriToken.textSecondary],
                    ),
                  ),
                ),
                _BarButton(
                  icon: Symbols.alternate_email_rounded,
                  label: mention ? 'On' : 'Off', //TODO: add l10n
                  color: mention
                      ? colors[NeriToken.primary]
                      : colors[NeriToken.textPlaceholder],
                  onTap: composer.toggleMentionReplies,
                ),
                _BarButton(
                  icon: Symbols.close_rounded,
                  onTap: composer.clearReplies,
                ),
              ],
            ),
          ),
          for (final message in replyTo)
            SizedBox(
              height: rowHeight,
              child: Row(
                children: [
                  Expanded(
                    child: ReplyPreview(message: PartialMessage.of(message)),
                  ),
                  if (replyTo.length > 1)
                    _BarButton(
                      icon: Symbols.close_rounded,
                      onTap: () => composer.removeReply(message.id),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _BarButton extends StatelessWidget {
  const _BarButton({
    required this.icon,
    required this.onTap,
    this.label,
    this.color,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final sizing = context.neriSize;
    final color = this.color ?? context.neri[NeriToken.textSecondary];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: PressScale(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: sizing.space(NeriSpacingRole.sm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: sizing.space(NeriSpacingRole.xs),
            children: [
              Icon(icon, size: sizing.dimen(NeriDimen.iconSm), color: color),
              if (label case final label?)
                Text(
                  label,
                  style: context.neriText[NeriTextRole.bodySmall].copyWith(
                    color: color,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
