import 'package:drift/drift.dart';

import 'package:nerimobile/db/database.dart';
import 'package:nerimobile/db/tables/inboxes.dart';
import 'package:nerimobile/models/inbox.dart';
import 'package:nerimobile/models/user.dart';

part 'inbox_dao.g.dart';

@DriftAccessor(tables: [Inboxes])
class InboxDao extends DatabaseAccessor<NeriDatabase> with _$InboxDaoMixin {
  InboxDao(super.attachedDatabase);

  //drop inboxes without a recipient
  Future<List<Inbox>> all(Map<String, User> recipients) async {
    final rows = await attachedDatabase.managers.inboxes.get();

    return [
      for (final row in rows)
        if (recipients[row.recipientId] case final recipient?)
          _model(row, recipient),
    ];
  }

  Future<void> sync(Iterable<Inbox> list) async {
    final channelsId = list.map((inbox) => inbox.channelId).toList();

    await transaction(() async {
      await (delete(
        inboxes,
      )..where((t) => t.channelId.isNotIn(channelsId))).go();
      await (batch(
        (b) => b.insertAllOnConflictUpdate(inboxes, list.map(_row)),
      ));
    });
  }
}

InboxesCompanion _row(Inbox inbox) => InboxesCompanion.insert(
  id: inbox.id,
  channelId: inbox.channelId,
  recipientId: inbox.recipientId,
  lastSeen: Value(inbox.lastSeen),
  createdAt: inbox.createdAt,
);

Inbox _model(InboxRow row, User recipient) => Inbox(
  id: row.id,
  channelId: row.channelId,
  recipientId: row.recipientId,
  recipient: recipient,
  lastSeen: row.lastSeen,
  createdAt: row.createdAt,
);
