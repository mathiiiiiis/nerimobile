import 'package:drift/drift.dart';

import 'package:nerimobile/db/database.dart';
import 'package:nerimobile/db/tables/server_roles.dart';
import 'package:nerimobile/models/server_role.dart';

part 'server_role_dao.g.dart';

@DriftAccessor(tables: [ServerRoles])
class ServerRoleDao extends DatabaseAccessor<NeriDatabase>
    with _$ServerRoleDaoMixin {
  ServerRoleDao(super.attachedDatabase);

  Future<List<ServerRole>> all() async =>
      (await attachedDatabase.managers.serverRoles.get()).map(_model).toList();

  Future<void> sync(Iterable<ServerRole> list) async {
    final ids = list.map((role) => role.id).toList();

    await transaction(() async {
      await (delete(serverRoles)..where((t) => t.id.isNotIn(ids))).go();
      await batch(
        (b) => b.insertAllOnConflictUpdate(serverRoles, list.map(_row)),
      );
    });
  }
}

ServerRolesCompanion _row(ServerRole role) => ServerRolesCompanion.insert(
  id: role.id,
  serverId: role.serverId,
  name: role.name,
  hideRole: role.hideRole,
  hexColor: Value(role.hexColor),
  permissions: role.permissions,
  order: role.order,
  icon: Value(role.icon),
);

ServerRole _model(ServerRoleRow row) => ServerRole(
  id: row.id,
  serverId: row.serverId,
  name: row.name,
  hideRole: row.hideRole,
  hexColor: row.hexColor,
  permissions: row.permissions,
  order: row.order,
  icon: row.icon,
);
