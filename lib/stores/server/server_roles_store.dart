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

  void addServerRoles(List<ServerRole> list) {
    final next = {
      for (final entry in state.entries) entry.key: {...entry.value},
    };
    for (final role in list) {
      (next[role.serverId] ??= {})[role.id] = role;
    }
    state = next;
  }

  void addServerRole(String serverId, ServerRole role) => state = {
    ...state,
    serverId: {...?state[serverId], role.id: role},
  };
}
