import 'package:drift/drift.dart';

import 'package:nerimobile/db/database.dart';
import 'package:nerimobile/db/tables/recent_emojis.dart';
import 'package:nerimobile/stores/emoji/recent_emoji_store.dart';

part 'recent_emoji_dao.g.dart';

const maxRecentEmojis = 20;

@DriftAccessor(tables: [RecentEmojis])
class RecentEmojiDao extends DatabaseAccessor<NeriDatabase>
    with _$RecentEmojiDaoMixin {
  RecentEmojiDao(super.attachedDatabase);

  Future<List<RecentEmoji>> all() async {
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

    return [for (final row in rows) (key: row.emoji, custom: row.custom)];
  }

  Future<void> use(RecentEmoji emoji) async {
    await into(recentEmojis).insert(
      RecentEmojisCompanion.insert(
        emoji: emoji.key,
        custom: Value(emoji.custom),
        usedAt: DateTime.now().millisecondsSinceEpoch,
      ),
      mode: InsertMode.insertOrReplace,
    );

    final keep = await all();
    await (delete(
      recentEmojis,
    )..where((row) => row.emoji.isNotIn([for (final e in keep) e.key]))).go();
  }
}
