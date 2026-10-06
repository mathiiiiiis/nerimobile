import 'package:drift/drift.dart';

//own membership only
@DataClassName('ServerMemberRow')
class ServerMembers extends Table {
  TextColumn get id => text()();
  TextColumn get serverId => text()();
  TextColumn get userId => text()();
  TextColumn get nickname => text().nullable()();
  TextColumn get roleIds => text()();

  @override
  Set<Column> get primaryKey => {serverId};
}
