import 'package:flutter/material.dart';
import 'package:nerimobile/models/server_member.dart';
import 'package:nerimobile/models/server_role.dart';
import 'package:nerimobile/stores/channel_store.dart';
import 'package:nerimobile/stores/server_store.dart';
import 'package:nerimobile/stores/user_presence_store.dart';
import 'package:nerimobile/stores/user_store.dart';
import 'package:nerimobile/theme/app_theme.dart';
import 'package:nerimobile/utils/bitwise.dart';
import 'package:nerimobile/utils/channel_permission_flag.dart';
import 'package:nerimobile/utils/colors.dart';
import 'package:nerimobile/utils/role_permission_flag.dart';
import 'package:nerimobile/views/app/server_clan_tag.dart';
import 'package:nerimobile/views/app/user_presence.dart';
import 'package:nerimobile/views/avatar.dart';
import 'package:nerimobile/views/cdn_icon.dart';
import 'package:signals/signals_flutter.dart';

final _offlineRole = ServerRole(
  id: 'offline',
  serverId: '',
  name: '',
  permissions: 0,
  order: 0,
  hideRole: false,
);

List<({ServerRole role, List<ServerMember> members})> _buildCategorizedMembers(
  List<ServerRole> roles,
  Iterable<ServerMember> serverMembers,
) {
  final channelPermissions = channelStore.currentPermissions();
  final serverRoles = serverStore.currentServerRoles.value;

  final defaultRole = serverStore.currentServerDefaultRole();
  final sortedRoles = serverStore.sortedRoles
      .where((r) => !r.hideRole)
      .toList();

  final roleOrder = <String, int>{
    for (var i = 0; i < sortedRoles.length; i++) sortedRoles[i].id: i,
  };

  final buckets = <String, List<ServerMember>>{};
  final offlineMembers = <ServerMember>[];

  final hasDefaultChannelPerm = hasBit(
    channelPermissions[defaultRole?.id],
    ChannelPermissionFlag.publicChannel.bit,
  );

  final hasDefaultRolePerm = hasBit(
    defaultRole?.permissions,
    RolePermissionFlag.admin.bit,
  );

  final isDefaultPublic = hasDefaultChannelPerm || hasDefaultRolePerm;

  for (final member in serverMembers) {
    final isCreator = member.userId == serverStore.currentServer()?.createdById;
    var canViewChannel = isCreator || isDefaultPublic;

    String? topRoleId;
    int? bestIndex;

    for (final roleId in member.roleIds) {
      if (!canViewChannel) {
        final role = serverRoles?[roleId];
        canViewChannel =
            hasBit(role?.permissions, RolePermissionFlag.admin.bit) ||
            hasBit(
              channelPermissions[roleId],
              ChannelPermissionFlag.publicChannel.bit,
            );
      }

      final idx = roleOrder[roleId];
      if (idx == null) continue;
      if (bestIndex == null || idx < bestIndex) {
        bestIndex = idx;
        topRoleId = roleId;
      }
    }

    if (!canViewChannel) continue;

    final offline = !userPresenceStore.presences.containsKey(member.userId);
    if (offline) {
      offlineMembers.add(member);
      continue;
    }

    if (topRoleId == null) {
      if (defaultRole != null) {
        (buckets[defaultRole.id] ??= []).add(member);
      }
      continue;
    }
    (buckets[topRoleId] ??= []).add(member);
  }

  return [
    for (final role in sortedRoles)
      if (buckets.containsKey(role.id))
        (role: role, members: buckets[role.id]!),
    if (offlineMembers.isNotEmpty)
      (role: _offlineRole, members: offlineMembers),
  ];
}

class ServerMemberList extends StatefulWidget {
  const ServerMemberList({super.key});
  @override
  State<ServerMemberList> createState() => _ServerMemberListState();
}

class _ServerMemberListState extends State<ServerMemberList> with SignalsMixin {
  late final _categorizedServerMembers = createComputed(() {
    final roles = serverStore.currentServerRoles.value?.values.toList();
    final serverMembers = serverStore.currentServerMembers.value?.values;
    if (roles == null || serverMembers == null) return [];

    return _buildCategorizedMembers(roles, serverMembers);
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Column(
        children: [
          Expanded(
            child: Watch((context) {
              final categories = _categorizedServerMembers.value;

              final items = <({String type, String id, int count})>[
                for (final category in categories) ...[
                  (
                    type: 'role',
                    id: category.role.id,
                    count: category.members.length,
                  ),
                  for (final member in category.members)
                    (type: 'member', id: member.userId, count: 0),
                ],
              ];

              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (ctx, i) {
                  final item = items[i];
                  if (item.type == 'role') {
                    return RoleHeader(
                      key: ValueKey('role_${item.id}'),
                      id: item.id,
                      count: item.count,
                    );
                  }
                  return MemberTile(
                    key: ValueKey('member_${item.id}'),
                    id: item.id,
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class RoleHeader extends StatelessWidget {
  final String id;
  final int count;
  const RoleHeader({super.key, required this.id, required this.count});

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final offlineRole = id == "offline";
      final role = serverStore.currentServerRoles.value?[id];
      if (!offlineRole && role == null) return const SizedBox.shrink();

      return Padding(
        padding: EdgeInsets.only(bottom: 2.0, right: 8.0, left: 8.0),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: Ink(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            child: InkWell(
              hoverColor: AppTheme.itemHoveredBg,
              borderRadius: BorderRadius.circular(8),
              onTap: () {},
              highlightColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 6.0,
                  horizontal: 12.0,
                ),
                child: Row(
                  spacing: 8,
                  children: [
                    if (role?.icon != null) CdnIcon(serverRole: role, size: 12),

                    Transform.translate(
                      offset: Offset(0, -1),
                      child: Text(
                        "${role?.name ?? "Offline"} ($count)",
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class MemberTile extends StatelessWidget {
  final String id;
  const MemberTile({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final member = serverStore.currentServerMembers.value?[id];
      final user = userStore.users[id];
      if (member == null) return const SizedBox.shrink();
      if (user == null) return const SizedBox.shrink();

      final color = serverStore.memberTopColor(member);
      final clan = user.profile?.clan;

      return Padding(
        padding: EdgeInsets.only(bottom: 2.0, right: 8.0, left: 8.0),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: Ink(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            child: InkWell(
              hoverColor: AppTheme.itemHoveredBg,
              borderRadius: BorderRadius.circular(8),
              onTap: () {},
              highlightColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 6.0,
                  horizontal: 12.0,
                ),
                child: Row(
                  spacing: 8,
                  children: [
                    Avatar(user: user, size: AvatarSize.md),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            spacing: 2,
                            children: [
                              Flexible(
                                child: buildColoredName(
                                  member.nickname ?? user.username,
                                  hexColor: color,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              if (clan != null) ServerClanTag(clan: clan),
                            ],
                          ),
                          UserPresence(userId: user.id, showOffline: false),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
