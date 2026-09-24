import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nerimobile/models/custom_emoji.dart';
import 'package:nerimobile/utils/emoji_shortcodes.dart';

final customEmojisProvider =
    NotifierProvider<CustomEmojiNotifier, Map<String, List<CustomEmoji>>>(
      CustomEmojiNotifier.new,
    );

//ensures every shortcode is unique
final uniqueCustomEmojisProvider = Provider<Map<String, List<CustomEmoji>>>((
  ref,
) {
  final counts = <String, int>{};

  CustomEmoji unique(CustomEmoji emoji) {
    var count = counts[emoji.name] ?? 0;
    if (emojiShortcodes.containsKey(emoji.name)) count++;
    counts[emoji.name] = count + 1;

    return count == 0 ? emoji : emoji.renamed('${emoji.name}-$count');
  }

  return {
    for (final MapEntry(key: serverId, value: emojis)
        in ref.watch(customEmojisProvider).entries)
      serverId: [for (final emoji in emojis) unique(emoji)],
  };
});

final customEmojiNamesProvider = Provider<Map<String, CustomEmoji>>(
  (ref) => {
    for (final emojis in ref.watch(uniqueCustomEmojisProvider).values)
      for (final emoji in emojis) emoji.name: emoji,
  },
);

class CustomEmojiNotifier extends Notifier<Map<String, List<CustomEmoji>>> {
  @override
  Map<String, List<CustomEmoji>> build() => const {};

  void setEmojis(List<CustomEmoji> emojis) {
    final byServer = <String, List<CustomEmoji>>{};
    for (final emoji in emojis) {
      (byServer[emoji.serverId] ??= []).add(emoji);
    }

    state = byServer;
  }

  void add(CustomEmoji emoji) => state = {
    ...state,
    emoji.serverId: [...?state[emoji.serverId], emoji],
  };

  void remove(String serverId, String emojiId) => state = {
    ...state,
    serverId: [
      for (final emoji in state[serverId] ?? const <CustomEmoji>[])
        if (emoji.id != emojiId) emoji,
    ],
  };

  void rename(String serverId, String emojiId, String name) => state = {
    ...state,
    serverId: [
      for (final emoji in state[serverId] ?? const <CustomEmoji>[])
        if (emoji.id == emojiId) emoji.renamed(name) else emoji,
    ],
  };
}
