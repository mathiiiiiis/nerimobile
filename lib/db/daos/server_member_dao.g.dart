// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_member_dao.dart';

// ignore_for_file: type=lint
mixin _$ServerMemberDaoMixin on DatabaseAccessor<NeriDatabase> {
  $ServerMembersTable get serverMembers => attachedDatabase.serverMembers;
  ServerMemberDaoManager get managers => ServerMemberDaoManager(this);
}

class ServerMemberDaoManager {
  final _$ServerMemberDaoMixin _db;
  ServerMemberDaoManager(this._db);
  $$ServerMembersTableTableManager get serverMembers =>
      $$ServerMembersTableTableManager(_db.attachedDatabase, _db.serverMembers);
}
