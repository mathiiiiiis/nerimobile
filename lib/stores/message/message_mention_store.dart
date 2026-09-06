import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nerimobile/models/message_mention.dart';

final messageMentionsProvider =
    NotifierProvider<MessageMentionsNotifier, Map<String, MessageMention>>(
      MessageMentionsNotifier.new,
    );

class MessageMentionsNotifier extends Notifier<Map<String, MessageMention>> {
  @override
  Map<String, MessageMention> build() => const {};

  void setMentions(List<MessageMention> list) {
    final next = <String, MessageMention>{};
    for (final mention in list) {
      final existing = next[mention.channelId];
      if (existing != null) {
        existing.count += 1;
      } else {
        next[mention.channelId] = mention;
      }
    }
    state = next;
  }

  void increment({
    required String channelId,
    required String userId,
    String? serverId,
  }) {
    final current = state[channelId];
    state = {
      ...state,
      channelId: MessageMention(
        channelId: channelId,
        serverId: serverId,
        count: (current?.count ?? 0) + 1,
      ),
    };
  }

  void clear(String channelId) => state = {...state}..remove(channelId);
}
