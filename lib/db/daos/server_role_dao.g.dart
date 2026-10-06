// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_role_dao.dart';

// ignore_for_file: type=lint
mixin _$ServerRoleDaoMixin on DatabaseAccessor<NeriDatabase> {
  $ServerRolesTable get serverRoles => attachedDatabase.serverRoles;
  ServerRoleDaoManager get managers => ServerRoleDaoManager(this);
}

class ServerRoleDaoManager {
  final _$ServerRoleDaoMixin _db;
  ServerRoleDaoManager(this._db);
  $$ServerRolesTableTableManager get serverRoles =>
      $$ServerRolesTableTableManager(_db.attachedDatabase, _db.serverRoles);
}
