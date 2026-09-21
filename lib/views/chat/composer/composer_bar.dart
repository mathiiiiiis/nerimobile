import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:nerimobile/models/message.dart';
import 'package:nerimobile/stores/composer/composer_store.dart';

import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
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
    final sizing = context.neriSize;
    final (:replyTo, :editing, :attachment) = ref.watch(
      composerProvider(channelId).select(
        (c) =>
            (replyTo: c.replyTo, editing: c.editing, attachment: c.attachment),
      ),
    );

    final bars = [
      if (editing != null)
        _EditBar(channelId: channelId)
      else ...[
        if (replyTo.isNotEmpty)
          _ReplyBar(channelId: channelId, replyTo: replyTo),
        if (attachment != null)
          _AttachmentBar(channelId: channelId, attachment: attachment),
      ],
    ];

    return AnimatedSize(
      duration: _resize,
      curve: Curves.easeOut,
      alignment: Alignment.bottomCenter,
      child: bars.isEmpty
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: EdgeInsets.fromLTRB(
                sizing.space(NeriSpacingRole.md),
                0,
                0,
                sizing.space(NeriSpacingRole.xs),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: bars,
              ),
            ),
    );
  }
}

class _EditBar extends ConsumerWidget {
  const _EditBar({required this.channelId});

  final String channelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _BarHeader(
      icon: Symbols.edit_rounded,
      label: 'Editing message', //TODO: add l10n
      actions: [
        _BarButton(
          icon: Symbols.close_rounded,
          onTap: ref.read(composerProvider(channelId).notifier).cancelEdit,
        ),
      ],
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
          _BarHeader(
            icon: Symbols.reply_rounded,
            label: replyTo.length == 1
                ? 'Replying to'
                : 'Replying to ${replyTo.length} messages',
            actions: [
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
          for (final message in replyTo)
            SizedBox(
              height: context.neriSize.dimen(NeriDimen.replyHeight),
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

class _AttachmentBar extends ConsumerWidget {
  const _AttachmentBar({required this.channelId, required this.attachment});

  final String channelId;
  final ComposerAttachment attachment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sizing = context.neriSize;
    final size = sizing.dimen(NeriDimen.attachmentCard);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: sizing.space(NeriSpacingRole.xs),
      children: [
        _BarHeader(
          icon: Symbols.attach_file_rounded,
          label: attachment.name,
          actions: [
            _BarButton(
              icon: Symbols.close_rounded,
              onTap: ref
                  .read(composerProvider(channelId).notifier)
                  .removeAttachment,
            ),
          ],
        ),
        if (attachment.isImage)
          ClipRRect(
            borderRadius: sizing.rounded(NeriRadiusRole.md),
            child: TickerMode(
              enabled: false,
              child: Image.file(
                File(attachment.path),
                width: size,
                height: size,
                fit: BoxFit.cover,
                cacheWidth: (size * MediaQuery.devicePixelRatioOf(context))
                    .round(),
                //hide formats platform cant decode
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ),
      ],
    );
  }
}

class _BarHeader extends StatelessWidget {
  const _BarHeader({
    required this.icon,
    required this.label,
    required this.actions,
  });

  final IconData icon;
  final String label;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;

    return SizedBox(
      height: sizing.dimen(NeriDimen.replyHeight),
      child: Row(
        spacing: sizing.space(NeriSpacingRole.xs),
        children: [
          Icon(
            icon,
            size: sizing.dimen(NeriDimen.iconSm),
            color: colors[NeriToken.textSecondary],
          ),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.neriText[NeriTextRole.bodySmall].copyWith(
                color: colors[NeriToken.textSecondary],
              ),
            ),
          ),
          ...actions,
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
