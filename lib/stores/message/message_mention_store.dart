import 'package:nerimobile/models/message_mention.dart';
import 'package:signals/signals_flutter.dart';

final messageMentionStore = MessageMentionStore();

class MessageMentionStore {
  final mentions = mapSignal<String, MessageMention>({});

  void setMentions(List<MessageMention> list) {
    mentions.clear();
    for (final mention in list) {
      final existing = mentions[mention.channelId];
      if (existing != null) {
        existing.count += 1;
      } else {
        mentions[mention.channelId] = mention;
      }
    }
  }
}
