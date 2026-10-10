import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nerimobile/models/server_role.dart';

final serverRolesProvider =
    NotifierProvider<ServerRolesNotifier, Map<String, Map<String, ServerRole>>>(
      ServerRolesNotifier.new,
    );

class ServerRolesNotifier
    extends Notifier<Map<String, Map<String, ServerRole>>> {
  @override
  Map<String, Map<String, ServerRole>> build() => const {};

  void setServerRoles(List<ServerRole> list) => state = _merged(const {}, list);

  void addServerRoles(List<ServerRole> list) => state = _merged(state, list);

  Map<String, Map<String, ServerRole>> _merged(
    Map<String, Map<String, ServerRole>> base,
    List<ServerRole> list,
  ) {
    final next = {
      for (final entry in base.entries) entry.key: {...entry.value},
    };
    for (final role in list) {
      (next[role.serverId] ??= {})[role.id] = role;
    }
    return next;
  }

  void addServerRole(String serverId, ServerRole role) => state = {
    ...state,
    serverId: {...?state[serverId], role.id: role},
  };

  void removeServer(String serverId) => state = {...state}..remove(serverId);

  void addCreatedRole(ServerRole role, String? defaultRoleId) {
    final shifted = [
      for (final other in state[role.serverId]?.values ?? <ServerRole>[])
        if (other.id != defaultRoleId) other,
    ]..sort((a, b) => a.order.compareTo(b.order));

    state = {
      ...state,
      role.serverId: {
        ...?state[role.serverId],
        for (final (index, other) in shifted.indexed)
          other.id: other.merge({'order': index + 3}),
        role.id: role,
      },
    };
  }

  void updateRole(
    String serverId,
    String roleId,
    Map<String, dynamic> updated,
  ) {
    final role = state[serverId]?[roleId];
    if (role == null) return;
    addServerRole(serverId, role.merge(updated));
  }

  void updateOrder(String serverId, List<String> roleIds) {
    final roles = state[serverId];
    if (roles == null) return;

    state = {
      ...state,
      serverId: {
        ...roles,
        for (final (index, id) in roleIds.indexed)
          if (roles[id] case final role?) id: role.merge({'order': index + 1}),
      },
    };
  }

  void removeRole(String serverId, String roleId) => state = {
    ...state,
    serverId: {...?state[serverId]}..remove(roleId),
  };
}
