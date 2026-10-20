import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import 'package:nerimobile/models/server.dart';
import 'package:nerimobile/services/api_client.dart';
import 'package:nerimobile/services/server_service.dart';
import 'package:nerimobile/services/socket_events.dart';
import 'package:nerimobile/stores/channel/channel_store.dart';
import 'package:nerimobile/stores/connection/connection_store.dart';
import 'package:nerimobile/stores/server/server_member_store.dart';
import 'package:nerimobile/stores/toast/toast_store.dart';
import 'package:nerimobile/stores/user/user_store.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/utils/colors.dart';
import 'package:nerimobile/views/avatar.dart';
import 'package:nerimobile/views/banner_image.dart';
import 'package:nerimobile/views/modal/bottom_sheet.dart';
import 'package:nerimobile/views/modal/confirm_dialog.dart';
import 'package:nerimobile/views/server/invite_sheet.dart';

Future<void> showServerContextMenu(
  BuildContext context,
  WidgetRef ref,
  Server server,
) {
  final channels = ref.read(channelsProvider);
  final unread = [
    for (final channelId in ref.read(channelNotificationsProvider).keys)
      if (channels[channelId]?.serverId == server.id) channelId,
  ];
  final owner = server.createdById == ref.read(currentUserIdProvider);
  final members = ref.read(serverMembersProvider)[server.id]?.length ?? 0;

  return showActionSheet(
    context,
    header: SheetHeader(
      title: server.name,
      subtitle: '$members members', //TODO: add l10n
      leading: Avatar(
        server: server,
        size: context.neriSize.dimen(NeriDimen.avatarMd),
        borderRadius: context.neriSize.rounded(NeriRadiusRole.md),
      ),
      leadingRadius: context.neriSize.rounded(NeriRadiusRole.md),
      background: BannerImage(
        path: server.banner,
        fallback: idColor(server.id),
      ),
    ),
    groups: [
      SheetGroup([
        SheetAction(
          icon: Symbols.person_add_rounded,
          label: 'Invite people', //TODO: add l10n
          onTap: () => showInviteSheet(context, server),
        ),
      ]),
      SheetGroup([
        SheetAction(
          icon: Symbols.mark_chat_read_rounded,
          label: unread.isEmpty
              ? 'Nothing unread'
              : 'Mark as read', //TODO: add l10n
          enabled: unread.isNotEmpty,
          onTap: () {
            final connection = ref.read(connectionProvider.notifier);
            for (final channelId in unread) {
              connection.send(notificationDismissEvent, {
                'channelId': channelId,
              });
            }
          },
        ),
      ]),
      SheetGroup([
        SheetAction(
          icon: Symbols.id_card_rounded,
          label: 'Copy ID', //TODO: add l10n
          onTap: () => Clipboard.setData(ClipboardData(text: server.id)),
        ),
      ]),
      SheetGroup([
        if (!owner) //owners need to delete the server
          SheetAction(
            icon: Symbols.logout_rounded,
            label: 'Leave server', //TODO: add l10n
            destructive: true,
            onTap: () => _leave(context, ref, server),
          ),
      ]),
    ],
  );
}

Future<void> _leave(BuildContext context, WidgetRef ref, Server server) async {
  if (!context.mounted) return;
  final router = GoRouter.of(context);

  final confirmed = await showConfirmDialog(
    context,
    title: 'Leave ${server.name}?', //TODO: add l10n
    message: 'You can join back anytime', //TODO: add l10n
    confirmLabel: 'Leave', //TODO: add l10n
    destructive: true,
  );
  if (!confirmed) return;

  try {
    await leaveServer(ref.read(dioProvider), server.id);
  } on DioException {
    ref
        .read(toastProvider.notifier)
        .show(
          'Could not leave "${server.name}"', //TODO: add l10n
          icon: Symbols.error_rounded,
          alert: true,
        );
    return;
  }

  final path = router.routerDelegate.currentConfiguration.uri.path;
  if (path.startsWith('/app/servers/${server.id}')) router.go('/app/servers');
}
