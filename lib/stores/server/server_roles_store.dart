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
}
