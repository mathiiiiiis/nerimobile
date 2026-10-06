import 'package:drift/drift.dart';

@DataClassName('ServerRoleRow')
class ServerRoles extends Table {
  TextColumn get id => text()();
  TextColumn get serverId => text()();
  TextColumn get name => text()();
  BoolColumn get hideRole => boolean()();
  TextColumn get hexColor => text().nullable()();
  IntColumn get permissions => integer()();
  IntColumn get order => integer()();
  TextColumn get icon => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
