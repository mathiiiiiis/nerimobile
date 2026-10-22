import 'package:drift/drift.dart';

@DataClassName('UserRow')
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get username => text()();
  TextColumn get tag => text().withDefault(const Constant(''))();
  TextColumn get hexColor => text()();
  TextColumn get avatar => text().nullable()();
  TextColumn get banner => text().nullable()();
  IntColumn get badges => integer().withDefault(const Constant(0))();
  IntColumn get font => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
