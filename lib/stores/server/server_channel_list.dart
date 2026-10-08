import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nerimobile/models/channel.dart';
import 'package:nerimobile/stores/channel/channel_store.dart';
import 'package:nerimobile/stores/server/server_permissions.dart';

typedef ChannelGroup = ({Channel? category, List<Channel> channels});

final serverChannelGroupsProvider = Provider.family<List<ChannelGroup>, String>(
  (ref, serverId) {
    final access = ref.watch(serverAccessProvider(serverId));
    if (access == null) return const [];

    final channels = [
      for (final channel in ref.watch(channelsProvider).values)
        if (channel.serverId == serverId) channel,
    ]..sort(_byOrder);
    final categories = [
      for (final channel in channels)
        if (channel.type == ChannelType.category.value) channel,
    ];
    final categoryIds = {for (final category in categories) category.id};

    final grouped = <String?, List<Channel>>{};
    for (final channel in channels) {
      if (channel.type == ChannelType.category.value) continue;
      if (!canViewChannel(access, channel)) continue;

      final categoryId = categoryIds.contains(channel.categoryId)
          ? channel.categoryId
          : null;
      (grouped[categoryId] ??= []).add(channel);
    }

    return [
      if (grouped[null] case final uncategorised?)
        (category: null, channels: uncategorised),
      for (final category in categories)
        (category: category, channels: grouped[category.id] ?? const []),
    ];
  },
);

int _byOrder(Channel a, Channel b) {
  final order = (a.order ?? 0).compareTo(b.order ?? 0);
  if (order != 0) return order;
  if (a.id.length != b.id.length) return a.id.length.compareTo(b.id.length);
  return a.id.compareTo(b.id);
}
