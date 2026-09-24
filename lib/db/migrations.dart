import 'package:drift/drift.dart';
import 'package:nerimobile/db/database.dart';

const cacheSchemaVersion = 4;

MigrationStrategy migrations(NeriDatabase db) => MigrationStrategy(
  onCreate: (m) => m.createAll(),
  onUpgrade: (m, from, to) async {
    if (from < 2) {
      await m.createTable(db.announcements);
      await m.createTable(db.dismissedAnnouncements);
    }
    if (from < 3) {
      await m.createTable(db.recentEmojis);
    } else if (from < 4) {
      await m.addColumn(db.recentEmojis, db.recentEmojis.custom);
    }
  },
);
