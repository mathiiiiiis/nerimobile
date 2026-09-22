import 'package:nerimobile/utils/emoji_catalog.dart';

final emojiEntries = <String, CatalogEmoji>{
  for (final emojis in emojiCatalog.values)
    for (final emoji in emojis) emoji.emoji: emoji,
};
