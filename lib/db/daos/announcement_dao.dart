import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:nerimobile/db/database.dart';
import 'package:nerimobile/db/tables/announcements.dart';
import 'package:nerimobile/models/post.dart';

part 'announcement_dao.g.dart';

@DriftAccessor(tables: [Announcements, DismissedAnnouncements])
class AnnouncementDao extends DatabaseAccessor<NeriDatabase>
    with _$AnnouncementDaoMixin {
  AnnouncementDao(super.attachedDatabase);

  Future<List<Post>> all() async {
    final rows = await (select(
      announcements,
    )..orderBy([(row) => OrderingTerm(expression: row.position)])).get();

    return [for (final row in rows) Post.fromJson(jsonDecode(row.payload))];
  }

  Future<void> sync(List<Map<String, dynamic>> payloads) async {
    await transaction(() async {
      await delete(announcements).go();
      await batch(
        (b) => b.insertAll(announcements, [
          for (final (index, payload) in payloads.indexed)
            AnnouncementsCompanion.insert(
              id: payload['id'] as String,
              payload: jsonEncode(payload),
              position: index,
            ),
        ]),
      );
    });
  }

  Future<Set<String>> dismissed() async {
    final rows = await attachedDatabase.managers.dismissedAnnouncements.get();
    return {for (final row in rows) row.id};
  }

  Future<void> dismiss(String id) => into(dismissedAnnouncements).insert(
    DismissedAnnouncementsCompanion.insert(id: id),
    mode: InsertMode.insertOrIgnore,
  );
}
