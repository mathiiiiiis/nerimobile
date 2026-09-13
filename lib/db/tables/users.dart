import 'package:drift/drift.dart';

@DataClassName('UserRow')
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get username => text()();
  TextColumn get hexColor => text()();
  TextColumn get avatar => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
