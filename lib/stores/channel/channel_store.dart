import 'package:nerimobile/stores/message/message_mention_store.dart';
import 'package:signals/signals_flutter.dart';
import '../../models/channel.dart';

final channelStore = ChannelStore();

class ChannelStore {
  final Signal<String?> currentChannelId = signal(null);

  final lastSeenServerChannelIds = mapSignal<String, int>({});

  final channels = mapSignal<String, Channel>({});

  void setLastSeenServerChannelIds(Map<String, int> ids) {
    lastSeenServerChannelIds.clear();
    lastSeenServerChannelIds.addAll(ids);
  }

  void updateLastSeenServerChannel(String channelId) {
    lastSeenServerChannelIds[channelId] =
        DateTime.now().millisecondsSinceEpoch + 10;
  }

  void addChannels(List<Channel> list) {
    channels.addAll({for (final c in list) c.id: c});
  }

  void addChannel(Channel channel) {
    channels[channel.id] = channel;
  }

  void removeChannel(String id) {
    channels.remove(id);
  }

  void setCurrentChannelId(String? id) {
    currentChannelId.value = id;
  }

  void updateLastMessagedAt(String channelId, int lastMessagedAt) {
    final channel = channels[channelId];
    if (channel == null) return;
    channels[channelId] = channel.copyWith(lastMessagedAt: lastMessagedAt);
  }

  late final Computed<Channel?> currentChannel = computed(() {
    return channels[currentChannelId.value];
  });

  late final Computed<Map<String, int>> currentPermissions = computed(() {
    final channel = currentChannel();
    final Map<String, int> channelPermissions = {
      for (final p in channel?.permissions ?? []) p.roleId: p.permissions,
    };
    return channelPermissions;
  });

  late final Computed<Map<String, int>> channelNotifications = computed(() {
    final channelMap = channels.value;
    if (channelMap.isEmpty) return {};

    final mentions = messageMentionStore.mentions.value;
    final lastSeen = channelStore.lastSeenServerChannelIds.value;
    final Map<String, int> notifications = {};

    for (final channel in channelMap.values) {
      final mentionCount = mentions[channel.id]?.count;

      if (mentionCount != null && mentionCount > 0) {
        notifications[channel.id] = mentionCount;
      } else {
        if (channel.serverId == null) continue;
        final lastSeenAt = lastSeen[channel.id];
        final hasNotSeen =
            channel.lastMessagedAt != null &&
            (lastSeenAt == null || channel.lastMessagedAt! > lastSeenAt);
        if (hasNotSeen) {
          notifications[channel.id] = -1;
        }
      }
    }

    return notifications;
  });
}
