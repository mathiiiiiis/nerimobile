import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nerimobile/models/server_member.dart';
import 'package:nerimobile/models/server_role.dart';
import 'package:nerimobile/stores/channel/channel_store.dart';
import 'package:nerimobile/stores/server/server_member_store.dart';
import 'package:nerimobile/stores/server/server_permissions.dart';
import 'package:nerimobile/stores/server/server_roles_store.dart';
import 'package:nerimobile/stores/server/server_store.dart';
import 'package:nerimobile/stores/user/user_presence_store.dart';
import 'package:nerimobile/stores/user/user_store.dart';

typedef MemberGroup = ({
  ServerRole? role,
  bool online,
  List<ServerMember> members,
});

typedef MemberListKey = ({String serverId, String channelId});

final memberGroupsProvider = Provider.family<List<MemberGroup>, MemberListKey>((
  ref,
  key,
) {
  final server = ref.watch(serversProvider)[key.serverId];
  final channel = ref.watch(channelsProvider)[key.channelId];
  if (server == null || channel == null) return const [];

  final roles = ref.watch(serverRolesProvider)[key.serverId] ?? const {};
  final sortedRoles = ref.watch(serverSortedRolesProvider(key.serverId));
  final presences = ref.watch(presencesProvider);
  final users = ref.watch(usersProvider);

  final byRole = <String, List<ServerMember>>{};
  final unplaced = <ServerMember>[];
  final offline = <ServerMember>[];

  for (final member
      in ref.watch(serverMembersProvider)[key.serverId]?.values ??
          const <ServerMember>[]) {
    final access = (server: server, member: member, roles: roles);
    if (!canViewChannel(access, channel)) continue;

    if (presences[member.userId] == null) {
      offline.add(member);
      continue;
    }

    final role =
        sortedRoles
            .where((r) => !r.hideRole && member.roleIds.contains(r.id))
            .firstOrNull ??
        roles[server.defaultRoleId];
    if (role == null || role.hideRole) {
      unplaced.add(member);
    } else {
      (byRole[role.id] ??= []).add(member);
    }
  }

  String name(ServerMember m) =>
      (m.nickname ?? users[m.userId]?.username ?? '').toLowerCase();
  int byName(ServerMember a, ServerMember b) => name(a).compareTo(name(b));

  return [
    for (final role in sortedRoles)
      if (byRole[role.id] case final members?)
        (role: role, online: true, members: members..sort(byName)),
    if (unplaced.isNotEmpty)
      (role: null, online: true, members: unplaced..sort(byName)),
    if (offline.isNotEmpty)
      (role: null, online: false, members: offline..sort(byName)),
  ];
});
