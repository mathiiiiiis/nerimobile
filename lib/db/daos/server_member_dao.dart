import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:nerimobile/db/database.dart';
import 'package:nerimobile/db/tables/server_members.dart';
import 'package:nerimobile/models/server_member.dart';

part 'server_member_dao.g.dart';

@DriftAccessor(tables: [ServerMembers])
class ServerMemberDao extends DatabaseAccessor<NeriDatabase>
    with _$ServerMemberDaoMixin {
  ServerMemberDao(super.attachedDatabase);

  Future<List<ServerMember>> all() async =>
      (await attachedDatabase.managers.serverMembers.get())
          .map(_model)
          .toList();

  Future<void> sync(Iterable<ServerMember> list) async {
    final serverIds = list.map((member) => member.serverId).toList();

    await transaction(() async {
      await (delete(
        serverMembers,
      )..where((t) => t.serverId.isNotIn(serverIds))).go();
      await batch(
        (b) => b.insertAllOnConflictUpdate(serverMembers, list.map(_row)),
      );
    });
  }
}

ServerMembersCompanion _row(ServerMember member) =>
    ServerMembersCompanion.insert(
      id: member.id,
      serverId: member.serverId,
      userId: member.userId,
      nickname: Value(member.nickname),
      roleIds: jsonEncode(member.roleIds.toList()),
    );

ServerMember _model(ServerMemberRow row) => ServerMember(
  id: row.id,
  serverId: row.serverId,
  userId: row.userId,
  nickname: row.nickname,
  roleIds: Set<String>.from(jsonDecode(row.roleIds) as List),
);
