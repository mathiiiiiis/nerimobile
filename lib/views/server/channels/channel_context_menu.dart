import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import 'package:nerimobile/models/channel.dart';
import 'package:nerimobile/services/socket_events.dart';
import 'package:nerimobile/stores/channel/channel_store.dart';
import 'package:nerimobile/stores/connection/connection_store.dart';
import 'package:nerimobile/stores/server/server_store.dart';
import 'package:nerimobile/stores/toast/toast_store.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/views/server/cdn_icon.dart';
import 'package:nerimobile/views/core/modal/bottom_sheet.dart';

Future<void> showChannelContextMenu(
  BuildContext context,
  WidgetRef ref,
  Channel channel,
) {
  final unread = ref.read(channelNotificationsProvider).containsKey(channel.id);
  final server = ref.read(serversProvider)[channel.serverId];

  return showActionSheet(
    context,
    header: SheetHeader(
      title: channel.name ?? '',
      subtitle: server?.name,
      leading: _ChannelIcon(channel),
    ),
    groups: [
      SheetGroup([
        SheetAction(
          icon: Symbols.mark_chat_read_rounded,
          label: unread ? 'Mark as read' : 'Nothing unread', //TODO: add l10n
          enabled: unread,
          onTap: () => ref.read(connectionProvider.notifier).send(
            notificationDismissEvent,
            {'channelId': channel.id},
          ),
        ),
      ]),
      SheetGroup([
        SheetAction(
          icon: Symbols.id_card_rounded,
          label: 'Copy ID', //TODO: add l10n
          onTap: () => ref
              .read(toastProvider.notifier)
              .copy(channel.id, label: 'ID copied'), //TODO: add l10n
        ),
      ]),
    ],
  );
}

class _ChannelIcon extends StatelessWidget {
  const _ChannelIcon(this.channel);

  final Channel channel;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;

    return Container(
      width: sizing.dimen(NeriDimen.avatarMd),
      height: sizing.dimen(NeriDimen.avatarMd),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors[NeriToken.surfaceHover],
        borderRadius: sizing.rounded(NeriRadiusRole.md),
      ),
      child: IconTheme.merge(
        data: IconThemeData(color: colors[NeriToken.textSecondary]),
        child: CdnIcon(
          channel: channel,
          size: sizing.dimen(NeriDimen.iconMd),
          fallbackIcon: Symbols.tag_rounded,
        ),
      ),
    );
  }
}
