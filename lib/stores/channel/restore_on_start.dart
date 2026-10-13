import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nerimobile/stores/channel/last_opened_store.dart';
import 'package:nerimobile/stores/server/server_store.dart';

enum RestoreOnStart {
  both(servers: true, dms: true),
  onlyServers(servers: true, dms: false),
  onlyDms(servers: false, dms: true),
  off(servers: false, dms: false);

  const RestoreOnStart({required this.servers, required this.dms});

  final bool servers;
  final bool dms;
}

//TODO: read from settings once they exist
final restoreOnStartProvider =
    NotifierProvider<RestoreOnStartNotifier, RestoreOnStart>(
      RestoreOnStartNotifier.new,
    );

class RestoreOnStartNotifier extends Notifier<RestoreOnStart> {
  @override
  RestoreOnStart build() => RestoreOnStart.onlyServers;

  void set(RestoreOnStart restore) => state = restore;
}

//server is null when the place is a dm
typedef LastPlace = ({String? serverId, String? channelId});

//last opened channels before closing
final lastPlaceProvider = Provider<LastPlace?>((ref) {
  final lastOpened = ref.watch(lastOpenedProvider);
  final servers = ref.watch(serversProvider);

  String? serverId;
  var serverAt = 0;
  for (final MapEntry(key: id, value: opened) in lastOpened.servers.entries) {
    if (opened.at > serverAt && servers.containsKey(id)) {
      serverId = id;
      serverAt = opened.at;
    }
  }
  final inboxId = ref.watch(lastOpenedInboxProvider);
  final inboxAt = lastOpened.inboxes[inboxId] ?? 0;

  if (serverId != null && serverAt >= inboxAt) {
    return (
      serverId: serverId,
      channelId: ref.watch(serverChannelToOpenProvider(serverId)),
    );
  }
  return inboxId == null ? null : (serverId: null, channelId: inboxId);
});

String startLocation(Ref ref) {
  final restore = ref.read(restoreOnStartProvider);

  return switch (ref.read(lastPlaceProvider)) {
    (serverId: final serverId?, channelId: final channelId?)
        when restore.servers =>
      '/app/servers/$serverId/$channelId',
    (serverId: final serverId?, channelId: _) => '/app/servers/$serverId',
    (serverId: null, channelId: final channelId?) when restore.dms =>
      '/app/inbox/$channelId',
    _ => '/app',
  };
}
