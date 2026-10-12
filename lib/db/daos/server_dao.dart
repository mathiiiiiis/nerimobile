import 'package:drift/drift.dart';

import 'package:nerimobile/db/database.dart';
import 'package:nerimobile/db/tables/servers.dart';
import 'package:nerimobile/models/server.dart';
import 'package:nerimobile/stores/channel/last_opened_store.dart';

part 'server_dao.g.dart';

@DriftAccessor(tables: [Servers])
class ServerDao extends DatabaseAccessor<NeriDatabase> with _$ServerDaoMixin {
  ServerDao(super.attachedDatabase);

  Future<List<Server>> all() async =>
      (await attachedDatabase.managers.servers.get()).map(_model).toList();

  Future<Map<String, OpenedServer>> lastOpened() async {
    final rows = await (select(
      servers,
    )..where((t) => t.lastOpenedAt.isNotNull())).get();
    return {
      for (final row in rows)
        row.id: (channelId: row.lastOpenedChannelId, at: row.lastOpenedAt!),
    };
  }

  Future<void> setLastOpened(String serverId, OpenedServer opened) =>
      (update(servers)..where((t) => t.id.equals(serverId))).write(
        ServersCompanion(
          lastOpenedChannelId: Value(opened.channelId),
          lastOpenedAt: Value(opened.at),
        ),
      );

  //left servers drop out of socket payload
  Future<void> sync(Iterable<Server> list) async {
    final ids = list.map((server) => server.id).toList();

    await transaction(() async {
      await (delete(servers)..where((t) => t.id.isNotIn(ids))).go();
      await batch((b) => b.insertAllOnConflictUpdate(servers, list.map(_row)));
    });
  }
}

ServersCompanion _row(Server server) => ServersCompanion.insert(
  id: server.id,
  name: server.name,
  avatar: Value(server.avatar),
  banner: Value(server.banner),
  hexColor: server.hexColor,
  defaultChannelId: server.defaultChannelId,
  defaultRoleId: server.defaultRoleId,
  createdById: server.createdById,
);

Server _model(ServerRow row) => Server(
  id: row.id,
  name: row.name,
  avatar: row.avatar,
  banner: row.banner,
  hexColor: row.hexColor,
  defaultChannelId: row.defaultChannelId,
  defaultRoleId: row.defaultRoleId,
  createdById: row.createdById,
);
