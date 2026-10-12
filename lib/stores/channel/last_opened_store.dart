import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nerimobile/db/daos/inbox_dao.dart';

import 'package:nerimobile/db/daos/server_dao.dart';
import 'package:nerimobile/db/database.dart';
import 'package:nerimobile/stores/channel/channel_store.dart';
import 'package:nerimobile/stores/connection/connection_store.dart';
import 'package:nerimobile/stores/inbox/inbox_store.dart';
import 'package:nerimobile/stores/server/server_member_store.dart';
import 'package:nerimobile/stores/server/server_permissions.dart';
import 'package:nerimobile/stores/server/server_roles_store.dart';

//null => fallback to server default
typedef OpenedServer = ({String? channelId, int at});

typedef LastOpened = ({
  Map<String, OpenedServer> servers,
  Map<String, int> inboxes,
});

final lastOpenedProvider = NotifierProvider<LastOpenedNotifier, LastOpened>(
  LastOpenedNotifier.new,
);

class LastOpenedNotifier extends Notifier<LastOpened> {
  @override
  LastOpened build() {
    ref.listen(channelsProvider, (_, _) => _prune());
    ref.listen(serverRolesProvider, (_, _) => _prune());
    ref.listen(serverMembersProvider, (_, _) => _prune());
    ref.listen(connectionProvider, (_, _) => _prune());
    return (servers: const {}, inboxes: const {});
  }

  NeriDatabase get _db => ref.read(databaseProvider);

  //entries before hydration finished are newer
  void hydrate(LastOpened cached) => state = (
    servers: {...cached.servers, ...state.servers},
    inboxes: {...cached.inboxes, ...state.inboxes},
  );

  void openServerChannel(String serverId, String channelId) {
    final opened = (
      channelId: channelId,
      at: DateTime.now().millisecondsSinceEpoch,
    );
    state = (
      servers: {...state.servers, serverId: opened},
      inboxes: state.inboxes,
    );
    ServerDao(_db).setLastOpened(serverId, opened);
  }

  void openInbox(String channelId) {
    final at = DateTime.now().millisecondsSinceEpoch;
    state = (
      servers: state.servers,
      inboxes: {...state.inboxes, channelId: at},
    );
    InboxDao(_db).setLastOpened(channelId, at);
  }

  //delted/hidden => fallback to default
  void _prune() {
    if (ref.read(connectionProvider) is! Authenticated) return;

    final channels = ref.read(channelsProvider);
    final cleared = <String, OpenedServer>{};

    for (final MapEntry(key: serverId, value: opened)
        in state.servers.entries) {
      final channelId = opened.channelId;
      if (channelId == null) continue;

      final channel = channels[channelId];
      final access = ref.read(serverAccessProvider(serverId));
      if (access == null) continue;
      if (channel != null && canViewChannel(access, channel)) continue;

      cleared[serverId] = (channelId: null, at: opened.at);
    }
    if (cleared.isEmpty) return;

    state = (servers: {...state.servers, ...cleared}, inboxes: state.inboxes);
    final dao = ServerDao(_db);
    for (final MapEntry(key: serverId, value: opened) in cleared.entries) {
      dao.setLastOpened(serverId, opened);
    }
  }
}

final serverChannelToOpenProvider = Provider.family<String?, String>((
  ref,
  serverId,
) {
  final access = ref.watch(serverAccessProvider(serverId));
  if (access == null) return null;

  final channels = ref.watch(channelsProvider);
  final saved = ref.watch(
    lastOpenedProvider.select((l) => l.servers[serverId]?.channelId),
  );
  for (final id in [saved, access.server.defaultChannelId]) {
    final channel = channels[id];
    if (channel != null &&
        channel.serverId == serverId &&
        canViewChannel(access, channel)) {
      return channel.id;
    }
  }
  return null;
});

final lastOpenedInboxProvider = Provider<String?>((ref) {
  final inboxes = ref.watch(inboxProvider);
  String? latest;
  var latestAt = 0;
  for (final MapEntry(key: channelId, value: at)
      in ref.watch(lastOpenedProvider).inboxes.entries) {
    if (at > latestAt && inboxes.containsKey(channelId)) {
      latest = channelId;
      latestAt = at;
    }
  }
  return latest;
});
