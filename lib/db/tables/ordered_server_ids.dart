import 'package:drift/drift.dart';

//rail order, also holds folder ids
@DataClassName('OrderedServerIdRow')
class OrderedServerIds extends Table {
  TextColumn get id => text()();
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
