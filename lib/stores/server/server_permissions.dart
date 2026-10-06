import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nerimobile/models/channel.dart';
import 'package:nerimobile/models/server.dart';
import 'package:nerimobile/models/server_member.dart';
import 'package:nerimobile/models/server_role.dart';

import 'package:nerimobile/stores/server/server_member_store.dart';
import 'package:nerimobile/stores/server/server_roles_store.dart';
import 'package:nerimobile/stores/server/server_store.dart';
import 'package:nerimobile/stores/user/user_store.dart';

import 'package:nerimobile/utils/bitwise.dart';
import 'package:nerimobile/utils/channel_permission_flag.dart';
import 'package:nerimobile/utils/role_permission_flag.dart';

typedef ServerAccess = ({
  Server server,
  ServerMember? member,
  Map<String, ServerRole> roles,
});

final serverAccessProvider = Provider.family<ServerAccess?, String>((
  ref,
  serverId,
) {
  final server = ref.watch(serversProvider)[serverId];
  if (server == null) return null;

  final userId = ref.watch(currentUserIdProvider);
  return (
    server: server,
    member: ref.watch(serverMembersProvider)[serverId]?[userId],
    roles: ref.watch(serverRolesProvider)[serverId] ?? const {},
  );
});

int memberPermissions(ServerAccess access) {
  final (:server, :member, :roles) = access;
  var bits = roles[server.defaultRoleId]?.permissions ?? 0;
  for (final roleId in member?.roleIds ?? const <String>{}) {
    bits = addBit(bits, roles[roleId]?.permissions ?? 0);
  }
  return bits;
}

bool memberHasPermission(ServerAccess access, RolePermissionFlag flag) {
  final member = access.member;
  if (member == null) return false;
  if (access.server.createdById == member.userId) return true;

  final bits = memberPermissions(access);
  return hasBit(bits, RolePermissionFlag.admin.bit) || hasBit(bits, flag.bit);
}

int channelPermissions(ServerAccess access, Channel channel) {
  final roleIds = {...?access.member?.roleIds, access.server.defaultRoleId};
  var bits = 0;
  for (final permission in channel.permissions ?? const []) {
    if (roleIds.contains(permission.roleId)) {
      bits = addBit(bits, permission.permissions);
    }
  }
  return bits;
}

bool channelHasPermissions(
  ServerAccess access,
  Channel channel,
  ChannelPermissionFlag flag,
) => hasBit(channelPermissions(access, channel), flag.bit);

bool canViewChannel(ServerAccess access, Channel channel) =>
    memberHasPermission(access, RolePermissionFlag.admin) ||
    channelHasPermissions(access, channel, ChannelPermissionFlag.publicChannel);

bool canSendMessage(ServerAccess access, Channel channel) {
  final member = access.member;
  if (member == null) return false;
  if (memberHasPermission(access, RolePermissionFlag.admin)) return true;
  if (member.isMuted) return false;

  return channelHasPermissions(
        access,
        channel,
        ChannelPermissionFlag.sendMessage,
      ) &&
      memberHasPermission(access, RolePermissionFlag.sendMessage);
}
