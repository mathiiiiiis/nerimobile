import 'package:nerimobile/models/channel.dart';
import 'package:nerimobile/models/server.dart';
import 'package:nerimobile/models/server_member.dart';
import 'package:nerimobile/models/server_role.dart';
import 'package:nerimobile/stores/channel_store.dart';
import 'package:nerimobile/stores/server_member_store.dart';
import 'package:nerimobile/stores/server_roles_store.dart';
import 'package:signals/signals_flutter.dart';

final serverStore = ServerStore();

class ServerStore {
  final Signal<String?> currentServerId = signal(null);
  final servers = mapSignal<String, Server>({});

  void addServers(List<Server> list) {
    servers.addAll({for (final s in list) s.id: s});
  }

  void addServer(Server server) {
    servers[server.id] = server;
  }

  void removeServer(String id) {
    servers.remove(id);
  }

  void setCurrentServerId(String? id) {
    currentServerId.value = id;
  }

  late final Computed<Server?> currentServer = computed(() {
    return servers[currentServerId.value];
  });

  late final Computed<Iterable<Channel>> currentServerChannels = computed(() {
    return channelStore.channels.values.where(
      (c) => c.serverId == currentServerId.value,
    );
  });

  late final Computed<MapSignal<String, ServerMember>?> currentServerMembers =
      computed(() {
        return serverMemberStore.serverMembers[currentServerId.value];
      });

  late final Computed<MapSignal<String, ServerRole>?> currentServerRoles =
      computed(() {
        return serverRolesStore.serverRoles[currentServerId.value];
      });

  late final sortedRoles = computed(() {
    final roles = currentServerRoles.value?.values.toList() ?? [];
    roles.sort((a, b) => b.order.compareTo(a.order));
    return roles;
  });

  ({String? hexColor, String? icon})? memberTopColorAndIcon(
    ServerMember? member,
  ) {
    if (member == null) return null;
    final sorted = sortedRoles.value;

    String? hexColor;
    String? icon;

    for (final role in sorted) {
      if (hexColor != null && icon != null) break;
      if (member.roleIds.contains(role.id)) {
        if (hexColor == null && role.hexColor != null) hexColor = role.hexColor;
        if (icon == null && role.icon != null) icon = role.icon;
      }
    }

    hexColor ??= currentServerDefaultRole.value?.hexColor;
    icon ??= currentServerDefaultRole.value?.icon;

    return (hexColor: hexColor, icon: icon);
  }

  String? memberTopColor(ServerMember? member) {
    if (member == null) return null;
    final sorted = sortedRoles.value;
    for (final role in sorted) {
      if (member.roleIds.contains(role.id) && role.hexColor != null) {
        return role.hexColor;
      }
    }

    return currentServerDefaultRole.value?.hexColor;
  }

  late final Computed<ServerRole?> currentServerDefaultRole = computed(() {
    final defaultRoleId = currentServer()?.defaultRoleId;
    return serverRolesStore.serverRoles[currentServerId.value]?[defaultRoleId];
  });

  late final Computed<Map<String, int>> notifications = computed(() {
    final notifications = channelStore.channelNotifications.value;
    final channelMap = channelStore.channels.value;
    final Map<String, int> result = {};

    for (final entry in notifications.entries) {
      final channel = channelMap[entry.key];
      if (channel?.serverId == null) continue;

      final serverId = channel!.serverId!;
      final current = result[serverId] ?? 0;

      if (entry.value > 0) {
        result[serverId] = (current < 0 ? 0 : current) + entry.value;
      } else if (entry.value == -1 && current == 0) {
        result[serverId] = -1;
      }
    }

    return result;
  });
}
