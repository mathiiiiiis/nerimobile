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

  void setChannels(List<Channel> list) =>
      state = {for (final c in list) c.id: c};

  void addChannels(List<Channel> list) =>
      state = {...state, for (final c in list) c.id: c};

  void addChannel(Channel channel) => state = {...state, channel.id: channel};

  void removeChannel(String id) => state = {...state}..remove(id);

  void removeServerChannels(String serverId) => state = {
    for (final entry in state.entries)
      if (entry.value.serverId != serverId) entry.key: entry.value,
  };

  //deleted category children become uncategorised
  void removeServerChannel(String id) {
    final next = {...state}..remove(id);
    for (final channel in state.values) {
      if (channel.categoryId == id) {
        next[channel.id] = channel.copyWith(categoryId: () => null);
      }
    }
    state = next;
  }

  void updateChannel(String id, Map<String, dynamic> updated) {
    final channel = state[id];
    if (channel == null) return;
    state = {
      ...state,
      id: channel.copyWith(
        name: updated['name'],
        icon: updated.containsKey('icon') ? () => updated['icon'] : null,
      ),
    };
  }

  //channels move into or out of a category
  void updateServerChannelOrder(
    List<String> orderedChannelIds,
    String? categoryId,
  ) {
    final next = {...state};
    for (final (index, id) in orderedChannelIds.indexed) {
      final channel = next[id];
      if (channel == null) continue;
      next[id] = channel.copyWith(
        order: index + 1,
        categoryId: () => categoryId,
      );
    }
    state = next;
  }

  void setChannelPermission(String id, ChannelPermission permission) {
    final channel = state[id];
    if (channel == null) return;
    state = {
      ...state,
      id: channel.copyWith(
        permissions: [
          for (final p in channel.permissions ?? const <ChannelPermission>[])
            if (p.roleId != permission.roleId) p,
          permission,
        ],
      ),
    };
  }

  void removeRolePermissions(String serverId, String roleId) {
    final next = {...state};
    for (final channel in state.values) {
      if (channel.serverId != serverId) continue;
      final permissions = channel.permissions;
      if (permissions == null || !permissions.any((p) => p.roleId == roleId)) {
        continue;
      }
      next[channel.id] = channel.copyWith(
        permissions: [...permissions.where((p) => p.roleId != roleId)],
      );
    }
    state = next;
  }

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
