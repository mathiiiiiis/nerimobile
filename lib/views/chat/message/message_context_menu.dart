import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:nerimobile/config.dart';
import 'package:nerimobile/models/gif.dart';

import 'package:nerimobile/models/message.dart';
import 'package:nerimobile/stores/composer/composer_store.dart';
import 'package:nerimobile/stores/gif/favorite_gif_store.dart';
import 'package:nerimobile/stores/message/message_store.dart';
import 'package:nerimobile/utils/url.dart';
import 'package:nerimobile/views/chat/message/message_access.dart';
import 'package:nerimobile/views/modal/bottom_sheet.dart';
import 'package:nerimobile/views/modal/confirm_dialog.dart';

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

  final actions = [
    if (favorite != null)
      SheetAction(
        icon: Symbols.star_rounded,
        filled: saved,
        label: saved
            ? 'Remove from favorites'
            : 'Add to favorites', //TODO: add l10n
        onTap: () => ref.read(favoriteGifsProvider.notifier).toggle(favorite),
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
        onTap: () => Clipboard.setData(ClipboardData(text: mediaUrl)),
      ),
    ],
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
        label: 'Quote', //TODO: add l10n
        onTap: () => ref
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
    if (message.content.isNotEmpty)
      SheetAction(
        icon: Symbols.content_copy_rounded,
        label: 'Copy text', //TODO: add l10n
        onTap: () => Clipboard.setData(ClipboardData(text: message.content)),
      ),
    if (access.canCopyId)
      SheetAction(
        icon: Symbols.id_card_rounded,
        label: 'Copy ID', //TODO: add l10n
        onTap: () => Clipboard.setData(ClipboardData(text: message.id)),
      ),
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
  ];
  if (actions.isEmpty) return;

  await showActionSheet(context, actions: actions);
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
