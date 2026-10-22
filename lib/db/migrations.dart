import 'package:drift/drift.dart';
import 'package:nerimobile/db/database.dart';

const cacheSchemaVersion = 12;

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
    if (from < 5) {
      await m.createTable(db.favoriteGifs);
    }
    if (from < 6) {
      await m.createTable(db.servers);
    } else if (from < 9) {
      await m.addColumn(db.servers, db.servers.banner);
    }
    if (from < 7) {
      await m.addColumn(db.channels, db.channels.permissions);
      await m.createTable(db.serverRoles);
      await m.createTable(db.serverMembers);
    }
    if (from < 8) {
      await m.createTable(db.orderedServerIds);
    }
    if (from < 10) {
      if (from >= 6) {
        await m.addColumn(db.servers, db.servers.lastOpenedChannelId);
        await m.addColumn(db.servers, db.servers.lastOpenedAt);
      }
      await m.addColumn(db.inboxes, db.inboxes.lastOpenedAt);
    }
    if (from < 11) {
      await m.addColumn(db.channels, db.channels.slowModeSeconds);
    }
    if (from < 12) {
      await m.addColumn(db.users, db.users.tag);
      await m.addColumn(db.users, db.users.banner);
      await m.addColumn(db.users, db.users.badges);
      await m.addColumn(db.users, db.users.font);
    }
  },
);
