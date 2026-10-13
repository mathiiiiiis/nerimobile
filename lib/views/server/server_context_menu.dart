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
import 'package:nerimobile/stores/user/user_store.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';
import 'package:nerimobile/views/avatar.dart';
import 'package:nerimobile/views/modal/bottom_sheet.dart';
import 'package:nerimobile/views/modal/confirm_dialog.dart';

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

  return showActionSheet(
    context,
    header: _ServerHeader(server),
    actions: [
      if (unread.isNotEmpty)
        SheetAction(
          icon: Symbols.mark_chat_read_rounded,
          label: 'Mark as read', //TODO: add l10n
          onTap: () {
            final connection = ref.read(connectionProvider.notifier);
            for (final channelId in unread) {
              connection.send(notificationDismissEvent, {
                'channelId': channelId,
              });
            }
          },
        ),
      SheetAction(
        icon: Symbols.id_card_rounded,
        label: 'Copy ID', //TODO: add l10n
        onTap: () => Clipboard.setData(ClipboardData(text: server.id)),
      ),
      if (!owner) //owners need to delete the server
        SheetAction(
          icon: Symbols.logout_rounded,
          label: 'Leave server', //TODO: add l10n
          destructive: true,
          onTap: () => _leave(context, ref, server),
        ),
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
    //TODO: toast once toasts exist
    return;
  }

  final path = router.routerDelegate.currentConfiguration.uri.path;
  if (path.startsWith('/app/servers/${server.id}')) router.go('/app/servers');
}

class _ServerHeader extends StatelessWidget {
  const _ServerHeader(this.server);

  final Server server;

  @override
  Widget build(BuildContext context) {
    final sizing = context.neriSize;

    return Row(
      spacing: sizing.space(NeriSpacingRole.md),
      children: [
        Avatar(server: server, size: sizing.dimen(NeriDimen.avatarMd)),
        Expanded(
          child: Text(
            server.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.neriText[NeriTextRole.titleMedium].copyWith(
              color: context.neri[NeriToken.text],
            ),
          ),
        ),
      ],
    );
  }
}
