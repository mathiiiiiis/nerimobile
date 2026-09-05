import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nerimobile/models/channel.dart';
import 'package:nerimobile/models/server.dart';
import 'package:nerimobile/models/server_member.dart';
import 'package:nerimobile/models/server_role.dart';
import 'package:nerimobile/stores/channel/channel_store.dart';
import 'package:nerimobile/stores/server/server_roles_store.dart';

final currentServerIdProvider =
    NotifierProvider<CurrentServerIdNotifier, String?>(
      CurrentServerIdNotifier.new,
    );

final serversProvider = NotifierProvider<ServersNotifier, Map<String, Server>>(
  ServersNotifier.new,
);

class CurrentServerIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setCurrentServerId(String? id) => state = id;
}

class ServersNotifier extends Notifier<Map<String, Server>> {
  @override
  Map<String, Server> build() => const {};

  void addServers(List<Server> list) =>
      state = {...state, for (final server in list) server.id: server};

  void addServer(Server server) => state = {...state, server.id: server};

  void removeServer(String id) => state = {...state}..remove(id);
}

final currentServerProvider = Provider<Server?>((ref) {
  final id = ref.watch(currentServerIdProvider);
  return id == null ? null : ref.watch(serversProvider)[id];
});

final currentServerChannelsProvider = Provider<Iterable<Channel>>((ref) {
  final id = ref.watch(currentServerIdProvider);
  return ref.watch(channelsProvider).values.where((c) => c.serverId == id);
});

final currentServerRolesProvider = Provider<Map<String, ServerRole>?>((ref) {
  final id = ref.watch(currentServerIdProvider);
  return id == null ? null : ref.watch(serverRolesProvider)[id];
});

final sortedRolesProvider = Provider<List<ServerRole>>((ref) {
  final roles = ref.watch(currentServerRolesProvider)?.values.toList() ?? [];
  roles.sort((a, b) => b.order.compareTo(a.order));
  return roles;
});

final currentServerDefaultRoleProvider = Provider<ServerRole?>((ref) {
  final defaultRoleId = ref.watch(currentServerProvider)?.defaultRoleId;
  return ref.watch(currentServerRolesProvider)?[defaultRoleId];
});

final serverNotificationsProvider = Provider<Map<String, int>>((ref) {
  final notifications = ref.watch(channelNotificationsProvider);
  final channels = ref.watch(channelsProvider);
  final result = <String, int>{};

  for (final entry in notifications.entries) {
    final serverId = channels[entry.key]?.serverId;
    if (serverId == null) continue;

    final current = result[serverId] ?? 0;
    if (entry.value > 0) {
      result[serverId] = (current < 0 ? 0 : current) + entry.value;
    } else if (entry.value == -1 && current == 0) {
      result[serverId] = -1;
    }
  }

  return result;
});

({String? hexColor, String? icon})? memberTopColorAndIcon(
  ServerMember? member,
  List<ServerRole> sortedRoles,
  ServerRole? defaultRole,
) {
  if (member == null) return null;

  String? hexColor;
  String? icon;

  for (final role in sortedRoles) {
    if (hexColor != null && icon != null) break;
    if (!member.roleIds.contains(role.id)) continue;
    hexColor ??= role.hexColor;
    icon ??= role.icon;
  }

  return (
    hexColor: hexColor ?? defaultRole?.hexColor,
    icon: icon ?? defaultRole?.icon,
  );
}

String? memberTopColor(
  ServerMember? member,
  List<ServerRole> sortedRoles,
  ServerRole? defaultRole,
) {
  if (member == null) return null;

  for (final role in sortedRoles) {
    if (member.roleIds.contains(role.id) && role.hexColor != null) {
      return role.hexColor;
    }
  }

  return defaultRole?.hexColor;
}
