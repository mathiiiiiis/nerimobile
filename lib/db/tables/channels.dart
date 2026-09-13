import 'package:drift/drift.dart';

class Channels extends Table {
  TextColumn get id => text()();
  IntColumn get type => integer()();
  TextColumn get name => text().nullable()();
  IntColumn get order => integer().nullable()();
  TextColumn get serverId => text().nullable()();
  TextColumn get icon => text().nullable()();
  TextColumn get categoryId => text().nullable()();
  IntColumn get lastMessagedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
