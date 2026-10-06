import 'package:drift/drift.dart';

import 'package:nerimobile/db/database.dart';
import 'package:nerimobile/db/tables/servers.dart';
import 'package:nerimobile/models/server.dart';

part 'server_dao.g.dart';

@DriftAccessor(tables: [Servers])
class ServerDao extends DatabaseAccessor<NeriDatabase> with _$ServerDaoMixin {
  ServerDao(super.attachedDatabase);

  Future<List<Server>> all() async =>
      (await attachedDatabase.managers.servers.get()).map(_model).toList();

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
  hexColor: server.hexColor,
  defaultChannelId: server.defaultChannelId,
  defaultRoleId: server.defaultRoleId,
  createdById: server.createdById,
);

Server _model(ServerRow row) => Server(
  id: row.id,
  name: row.name,
  avatar: row.avatar,
  hexColor: row.hexColor,
  defaultChannelId: row.defaultChannelId,
  defaultRoleId: row.defaultRoleId,
  createdById: row.createdById,
);
