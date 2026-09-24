import 'package:flutter/widgets.dart';

import 'package:nerimobile/utils/cached_svg_loader.dart';
import 'package:nerimobile/utils/emoji_catalog.dart';
import 'package:nerimobile/utils/emojis.dart';

const _warmCount = 64;

Future<void> warmEmojiCache(BuildContext context) async {
  for (final emoji in emojiCatalog.values.first.take(_warmCount)) {
    if (!context.mounted) return;

    await CachedSvgLoader(unicodeToTwemojiUrl(emoji.emoji)).loadBytes(context);
  }
}
