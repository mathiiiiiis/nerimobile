import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nerimobile/db/daos/recent_emoji_dao.dart';
import 'package:nerimobile/db/database.dart';

typedef RecentEmoji = ({String key, bool custom});

final recentEmojisProvider =
    AsyncNotifierProvider<RecentEmojiNotifier, List<RecentEmoji>>(
      RecentEmojiNotifier.new,
    );

class RecentEmojiNotifier extends AsyncNotifier<List<RecentEmoji>> {
  RecentEmojiDao get _dao => RecentEmojiDao(ref.read(databaseProvider));

  @override
  Future<List<RecentEmoji>> build() => _dao.all();

  Future<void> use(RecentEmoji emoji) async {
    await _dao.use(emoji);
    state = AsyncData(await _dao.all());
  }
}
