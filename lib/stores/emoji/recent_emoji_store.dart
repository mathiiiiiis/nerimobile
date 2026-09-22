import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nerimobile/db/daos/recent_emoji_dao.dart';
import 'package:nerimobile/db/database.dart';
import 'package:nerimobile/utils/emoji_catalog.dart';
import 'package:nerimobile/utils/emoji_entries.dart';

final recentEmojisProvider =
    AsyncNotifierProvider<RecentEmojiNotifier, List<CatalogEmoji>>(
      RecentEmojiNotifier.new,
    );

class RecentEmojiNotifier extends AsyncNotifier<List<CatalogEmoji>> {
  RecentEmojiDao get _dao => RecentEmojiDao(ref.read(databaseProvider));

  @override
  Future<List<CatalogEmoji>> build() => _load();

  Future<List<CatalogEmoji>> _load() async {
    final recents = await _dao.all();
    return [for (final emoji in recents) ?emojiEntries[emoji]];
  }

  Future<void> use(CatalogEmoji emoji) async {
    await _dao.use(emoji.emoji);
    state = AsyncData(await _load());
  }
}
