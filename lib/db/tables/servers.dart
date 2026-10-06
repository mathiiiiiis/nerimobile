import 'package:drift/drift.dart';

@DataClassName('ServerRow')
class Servers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get avatar => text().nullable()();
  TextColumn get hexColor => text()();
  TextColumn get defaultChannelId => text()();
  TextColumn get defaultRoleId => text()();
  TextColumn get createdById => text()();

  @override
  Set<Column> get primaryKey => {id};
}
