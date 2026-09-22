import 'package:drift/drift.dart';

import 'package:nerimobile/db/database.dart';
import 'package:nerimobile/db/tables/recent_emojis.dart';

part 'recent_emoji_dao.g.dart';

const maxRecentEmojis = 20;

@DriftAccessor(tables: [RecentEmojis])
class RecentEmojiDao extends DatabaseAccessor<NeriDatabase>
    with _$RecentEmojiDaoMixin {
  RecentEmojiDao(super.attachedDatabase);

  Future<List<String>> all() async {
    final rows =
        await (select(recentEmojis)
              ..orderBy([
                (row) => OrderingTerm(
                  expression: row.usedAt,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(maxRecentEmojis))
            .get();

    return [for (final row in rows) row.emoji];
  }

  Future<void> use(String emoji) async {
    await into(recentEmojis).insert(
      RecentEmojisCompanion.insert(
        emoji: emoji,
        usedAt: DateTime.now().millisecondsSinceEpoch,
      ),
      mode: InsertMode.insertOrReplace,
    );

    final keep = await all();
    await (delete(recentEmojis)..where((row) => row.emoji.isNotIn(keep))).go();
  }
}
