import 'package:drift/drift.dart';

class Inboxes extends Table {
  TextColumn get id => text()();
  TextColumn get channelId => text()();
  TextColumn get recipientId => text()();
  IntColumn get lastSeen => integer().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {channelId};
}
