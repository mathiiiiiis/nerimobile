import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nerimobile/models/inbox.dart';
import 'package:nerimobile/stores/channel/channel_store.dart';

final inboxProvider = NotifierProvider<InboxNotifier, Map<String, Inbox>>(
  InboxNotifier.new,
);

class InboxNotifier extends Notifier<Map<String, Inbox>> {
  @override
  Map<String, Inbox> build() => const {};

  void setInbox(List<Inbox> list) =>
      state = {for (final item in list) item.channelId: item};

  void addInbox(Inbox item) => state = {...state, item.channelId: item};

  void removeInbox(String channelId) => state = {...state}..remove(channelId);
}

final sortedInboxProvider = Provider<List<Inbox>>((ref) {
  final channels = ref.watch(channelsProvider);
  final items = ref.watch(inboxProvider).values.toList();

  items.sort((a, b) {
    final left = channels[a.channelId]?.lastMessagedAt ?? a.createdAt;
    final right = channels[b.channelId]?.lastMessagedAt ?? b.createdAt;
    return right.compareTo(left);
  });

  return items;
});
