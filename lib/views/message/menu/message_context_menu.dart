import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:nerimobile/config.dart';
import 'package:nerimobile/models/gif.dart';

import 'package:nerimobile/models/message.dart';
import 'package:nerimobile/stores/channel/channel_store.dart';
import 'package:nerimobile/stores/composer/composer_store.dart';
import 'package:nerimobile/stores/gif/favorite_gif_store.dart';
import 'package:nerimobile/stores/message/message_store.dart';
import 'package:nerimobile/stores/server/server_store.dart';
import 'package:nerimobile/stores/toast/toast_store.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/utils/format.dart';
import 'package:nerimobile/utils/url.dart';
import 'package:nerimobile/views/user/avatar.dart';
import 'package:nerimobile/views/message/message_access.dart';
import 'package:nerimobile/views/markup/markup.dart';
import 'package:nerimobile/views/core/modal/bottom_sheet.dart';
import 'package:nerimobile/views/core/modal/confirm_dialog.dart';

Future<void> showMessageContextMenu(
  BuildContext context,
  WidgetRef ref,
  Message message, {
  String? mediaUrl,
}) async {
  final access = MessageAccess.read(ref, message);
  final favorite = _favorite(message);
  final saved =
      favorite != null &&
      (await ref.read(
        favoriteGifsProvider.future,
      )).any((gif) => gif.url == favorite.url);

  if (!context.mounted) return;

  final groups = [
    SheetGroup([
      if (favorite != null)
        SheetAction(
          icon: Symbols.star_rounded,
          filled: saved,
          label: saved
              ? 'Remove from favorites'
              : 'Add to favorites', //TODO: add l10n
          onTap: () => ref.read(favoriteGifsProvider.notifier).toggle(favorite),
        ),
    ]),

    SheetGroup([
      if (access.canReply)
        SheetAction(
          icon: Symbols.reply_rounded,
          label: 'Reply', //TODO: add l10n
          onTap: () => ref
              .read(composerProvider(message.channelId).notifier)
              .reply(message),
        ),
      if (access.canQuote)
        SheetAction(
          icon: Symbols.format_quote_rounded,
          label: access.blocked ? 'Copy quote' : 'Quote', //TODO: add l10n
          onTap: () => access.blocked
              ? ref
                    .read(toastProvider.notifier)
                    .copy(
                      '[q:${message.id}]',
                      label: 'Quote copied', //TODO: add l10n
                    )
              : ref
                    .read(composerProvider(message.channelId).notifier)
                    .insert('[q:${message.id}]'),
        ),
      if (access.canEdit)
        SheetAction(
          icon: Symbols.edit_rounded,
          label: 'Edit', //TODO: add l10n
          onTap: () => ref
              .read(composerProvider(message.channelId).notifier)
              .edit(message),
        ),
    ]),

    SheetGroup([
      if (message.content.isNotEmpty)
        SheetAction(
          icon: Symbols.content_copy_rounded,
          label: 'Copy text', //TODO: add l10n
          onTap: () => ref
              .read(toastProvider.notifier)
              .copy(message.content, label: 'Text copied'), //TODO: add l10n
        ),
      if (mediaUrl != null) ...[
        SheetAction(
          icon: Symbols.open_in_new_rounded,
          label: 'Open in browser', //TODO: add l10n
          onTap: () => openExternal(mediaUrl),
        ),
        SheetAction(
          icon: Symbols.link_rounded,
          label: 'Copy media link', //TODO: add l10n
          onTap: () => ref
              .read(toastProvider.notifier)
              .copy(mediaUrl, label: 'Link copied'), //TODO: add l10n
        ),
      ],
      if (access.canCopyLink)
        SheetAction(
          icon: Symbols.insert_link_rounded,
          label: 'Copy message link', //TODO: add l10n
          onTap: () => ref
              .read(toastProvider.notifier)
              .copy(
                _messageLink(ref, message),
                label: 'Message link copied', //TODO: add l10n
              ),
        ),
      if (access.canCopyId)
        SheetAction(
          icon: Symbols.id_card_rounded,
          label: 'Copy ID', //TODO: add l10n
          onTap: () => ref
              .read(toastProvider.notifier)
              .copy(message.id, label: 'ID copied'), //TODO: add l10n
        ),
    ]),

    SheetGroup([
      if (access.canDelete)
        SheetAction(
          icon: Symbols.delete_rounded,
          label: 'Delete', //TODO: add l10n
          destructive: true,
          onTap: () => _delete(context, ref, message, confirm: !access.failed),
        ),
      if (access.canCancelUpload)
        SheetAction(
          icon: Symbols.cancel_rounded,
          label: 'Cancel upload', //TODO: add l10n
          destructive: true,
          onTap: () => ref
              .read(messagesProvider(message.channelId).notifier)
              .cancelUpload(message.id),
        ),
    ]),
  ];
  if (groups.every((group) => group.actions.isEmpty)) return;

  final author = (channelId: message.channelId, userId: message.createdBy.id);

  await showActionSheet(
    context,
    header: SheetHeader(
      title:
          ref.read(channelMemberNicknameProvider(author)) ??
          message.createdBy.username,
      titleColor: ref.read(channelMemberColorProvider(author)),
      caption: _preview(message),
      leading: Avatar(
        user: message.createdBy,
        size: context.neriSize.dimen(NeriDimen.avatarMd),
      ),
    ),
    groups: groups,
  );
}

Widget? _preview(Message message) {
  if (message.content.isNotEmpty) {
    return MarkupView(
      rawText: singleLine(message.content),
      mentions: message.mentions,
      inline: true,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
  if (message.attachments.isEmpty) return null;

  return const Text(
    'Sent an attachment', //TODO: add l10n
    style: TextStyle(fontStyle: FontStyle.italic),
  );
}

String _messageLink(WidgetRef ref, Message message) {
  final serverId = ref.read(channelsProvider)[message.channelId]?.serverId;
  final path = serverId == null
      ? 'inbox/${message.channelId}'
      : 'servers/$serverId/${message.channelId}';
  return '$appUrl$path?messageId=${message.id}';
}

FavoriteGif? _favorite(Message message) {
  final attachment = message.attachments.firstOrNull;
  if (attachment != null) {
    final path = attachment.path;
    if (path == null || !attachment.isAnimated || attachment.expireAt != null) {
      return null;
    }

    return FavoriteGif.link(
      '$cdnUrl$path',
      width: attachment.width,
      height: attachment.height,
    );
  }

  final embed = message.embed;
  final source = embed?.imageSource;
  if (embed == null || source == null) return null;
  if (embed.animated != true && embed.imageMime != 'image/gif') return null;

  return FavoriteGif.link(
    source,
    width: embed.imageWidth,
    height: embed.imageHeight,
  );
}

Future<void> _delete(
  BuildContext context,
  WidgetRef ref,
  Message message, {
  required bool confirm,
}) async {
  final messages = ref.read(messagesProvider(message.channelId).notifier);

  if (confirm) {
    if (!context.mounted) return;
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete message?', //TODO: add l10n
      message:
          'This will delete the message and cannot be undone.', //TODO: add l10n
      confirmLabel: 'Delete', //TODO: add l10n
      destructive: true,
    );
    if (!confirmed) return;
  }

  await messages.delete(message.id);
}
