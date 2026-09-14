import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nerimobile/db/connection.dart';
import 'package:nerimobile/db/migrations.dart';
import 'package:nerimobile/db/tables/announcements.dart';
import 'package:nerimobile/db/tables/channels.dart';
import 'package:nerimobile/db/tables/inboxes.dart';
import 'package:nerimobile/db/tables/users.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [Announcements, Channels, DismissedAnnouncements, Inboxes, Users],
)
class NeriDatabase extends _$NeriDatabase {
  NeriDatabase() : super(openConnection());
  NeriDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => cacheSchemaVersion;

  @override
  MigrationStrategy get migration => migrations(this);

  //cache belongs to logged in user, wiped after sign out
  Future<void> wipe() async {
    await transaction(() async {
      for (final table in allTables) {
        await delete(table).go();
      }
    });
  }
}

final databaseProvider = Provider<NeriDatabase>((ref) {
  final database = NeriDatabase();
  ref.onDispose(database.close);
  return database;
});
