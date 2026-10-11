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
    final categoryIds = [
      for (final channel in channels)
        if (channel.type == ChannelType.category.value) channel.id,
    ];

    final children = <String?, List<Channel>>{};
    final roots = <Channel>[];
    for (final channel in channels) {
      final isCategory = channel.type == ChannelType.category.value;
      if (!isCategory && !canViewChannel(access, channel)) continue;

      if (!isCategory && categoryIds.contains(channel.categoryId)) {
        (children[channel.categoryId!] ??= []).add(channel);
      } else {
        roots.add(channel);
      }
    }

    final groups = <ChannelGroup>[];
    for (final root in roots) {
      if (root.type == ChannelType.category.value) {
        groups.add((category: root, channels: children[root.id] ?? const []));
      } else if (groups.lastOrNull case (category: null, :final channels)) {
        channels.add(root);
      } else {
        groups.add((category: null, channels: [root]));
      }
    }
    return groups;
  },
);

int _byOrder(Channel a, Channel b) {
  final order = (a.order ?? 0).compareTo(b.order ?? 0);
  if (order != 0) return order;
  if (a.id.length != b.id.length) return a.id.length.compareTo(b.id.length);
  return a.id.compareTo(b.id);
}
