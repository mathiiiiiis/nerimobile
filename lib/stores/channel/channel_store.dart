import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nerimobile/stores/message/message_mention_store.dart';
import 'package:nerimobile/models/channel.dart';

final currentChannelIdProvider =
    NotifierProvider<CurrentChannelIdNotifier, String?>(
      CurrentChannelIdNotifier.new,
    );

final channelsProvider =
    NotifierProvider<ChannelsNotifier, Map<String, Channel>>(
      ChannelsNotifier.new,
    );

final lastSeenServerChannelIdsProvider =
    NotifierProvider<LastSeenServerChannelIdsNotifier, Map<String, int>>(
      LastSeenServerChannelIdsNotifier.new,
    );

class CurrentChannelIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setCurrentChannelId(String? id) => state = id;
}

class ChannelsNotifier extends Notifier<Map<String, Channel>> {
  @override
  Map<String, Channel> build() => const {};

  void addChannels(List<Channel> list) =>
      state = {...state, for (final c in list) c.id: c};

  void addChannel(Channel channel) => state = {...state, channel.id: channel};

  void removeChannel(String id) => state = {...state}..remove(id);

  void updateLastMessagedAt(String channelId, int lastMessagedAt) {
    final channel = state[channelId];
    if (channel == null) return;
    state = {
      ...state,
      channelId: channel.copyWith(lastMessagedAt: lastMessagedAt),
    };
  }
}

class LastSeenServerChannelIdsNotifier extends Notifier<Map<String, int>> {
  @override
  Map<String, int> build() => const {};

  void setLastSeenServerChannelIds(Map<String, int> ids) => state = {...ids};

  void updateLastSeenServerChannel(String channelId) =>
      state = {...state, channelId: DateTime.now().millisecondsSinceEpoch + 10};
}

final currentChannelProvider = Provider<Channel?>((ref) {
  final id = ref.watch(currentChannelIdProvider);
  return id == null ? null : ref.watch(channelsProvider)[id];
});

final currentPermissionsProvider = Provider<Map<String, int>>((ref) {
  final channel = ref.watch(currentChannelProvider);
  return {for (final p in channel?.permissions ?? []) p.roleId: p.permissions};
});

final channelNotificationsProvider = Provider<Map<String, int>>((ref) {
  final channels = ref.watch(channelsProvider);
  if (channels.isEmpty) return const {};

  final mentions = ref.watch(messageMentionsProvider);
  final lastSeen = ref.watch(lastSeenServerChannelIdsProvider);
  final notifications = <String, int>{};

  for (final channel in channels.values) {
    final mentionCount = mentions[channel.id]?.count;

    if (mentionCount != null && mentionCount > 0) {
      notifications[channel.id] = mentionCount;
      continue;
    }
    if (channel.serverId == null) continue;

    final lastSeenAt = lastSeen[channel.id];
    final hasNotSeen =
        channel.lastMessagedAt != null &&
        (lastSeenAt == null || channel.lastMessagedAt! > lastSeenAt);
    if (hasNotSeen) notifications[channel.id] = -1;
  }

  return notifications;
});
