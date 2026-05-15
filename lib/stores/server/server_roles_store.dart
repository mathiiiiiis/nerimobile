import 'package:nerimobile/models/server_role.dart';
import 'package:signals/signals_flutter.dart';

final serverRolesStore = ServerRolesStore();

class ServerRolesStore {
  final serverRoles = mapSignal<String, MapSignal<String, ServerRole>>({});

  MapSignal<String, ServerRole> _getOrCreate(String serverId) {
    if (!serverRoles.containsKey(serverId)) {
      serverRoles[serverId] = mapSignal<String, ServerRole>({});
    }
    return serverRoles[serverId]!;
  }

  void addServerRoles(List<ServerRole> list) {
    batch(() {
      for (final role in list) {
        _getOrCreate(role.serverId)[role.id] = role;
      }
    });
  }

  void addServerRole(String serverId, ServerRole role) {
    _getOrCreate(serverId)[role.id] = role;
  }
}
