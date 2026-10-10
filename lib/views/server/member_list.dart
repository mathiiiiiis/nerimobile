import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import 'package:nerimobile/models/server_member.dart';
import 'package:nerimobile/stores/connection/connection_store.dart';
import 'package:nerimobile/stores/server/server_member_list.dart';
import 'package:nerimobile/stores/server/server_member_store.dart';
import 'package:nerimobile/stores/server/server_store.dart';
import 'package:nerimobile/stores/user/user_store.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';
import 'package:nerimobile/utils/colors.dart';
import 'package:nerimobile/views/avatar.dart';
import 'package:nerimobile/views/cdn_icon.dart';
import 'package:nerimobile/views/chat/channel/channel_header.dart';
import 'package:nerimobile/views/dashboard/widget/dm_list_skeleton.dart';
import 'package:nerimobile/views/presence/presence_line.dart';
import 'package:nerimobile/views/shell/widgets/scroll_fade.dart';

const _offlineOpacity = 0.5;

class MembersPage extends StatelessWidget {
  const MembersPage({
    super.key,
    required this.serverId,
    required this.channelId,
  });

  final String serverId;
  final String channelId;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;

    return ColoredBox(
      color: colors[NeriToken.background],
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.all(sizing.space(NeriSpacingRole.md)),
              child: Row(
                spacing: sizing.space(NeriSpacingRole.sm),
                children: [
                  HeaderIconButton(
                    icon: Symbols.arrow_back_rounded,
                    onTap: () => context.canPop()
                        ? context.pop()
                        : context.go('/app/servers/$serverId/$channelId'),
                  ),
                  Text(
                    'Members', //TODO: add l10n
                    style: context.neriText[NeriTextRole.headlineSmall]
                        .copyWith(color: colors[NeriToken.text]),
                  ),
                ],
              ),
            ),
            Expanded(
              child: MemberList(
                serverId: serverId,
                channelId: channelId,
                surface: colors[NeriToken.background],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MemberList extends ConsumerWidget {
  const MemberList({
    super.key,
    required this.serverId,
    required this.channelId,
    required this.surface,
  });

  final String serverId;
  final String channelId;
  final Color surface;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sizing = context.neriSize;
    final groups = ref.watch(
      memberGroupsProvider((serverId: serverId, channelId: channelId)),
    );
    final unknown =
        ref.watch(connectionProvider) is! Authenticated &&
        (ref.watch(serverMembersProvider)[serverId]?.length ?? 0) <= 1;
    final entries = [
      for (final group in groups) ...[
        (group: group, member: null),
        for (final member in group.members) (group: group, member: member),
      ],
    ];

    return ScrollFade(
      color: surface,
      child: unknown
          ? const DmListSkeleton()
          : ListView.builder(
              padding: EdgeInsets.only(
                bottom: sizing.dimen(NeriDimen.fadeHeight),
              ),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final (:group, :member) = entries[index];
                return member == null
                    ? _GroupHeader(group)
                    : _MemberRow(
                        serverId: serverId,
                        member: member,
                        online: group.online,
                        surface: surface,
                      );
              },
            ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader(this.group);

  final MemberGroup group;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final style = context.neriText[NeriTextRole.labelSmall].copyWith(
      color: colors[NeriToken.textTertiary],
    );
    final label =
        group.role?.name ??
        (group.online ? 'Online' : 'Offline'); //TODO: add l10n

    return Padding(
      padding: EdgeInsets.fromLTRB(
        sizing.space(NeriSpacingRole.md),
        sizing.space(NeriSpacingRole.md),
        sizing.space(NeriSpacingRole.md),
        sizing.space(NeriSpacingRole.xs),
      ),
      child: Row(
        spacing: sizing.space(NeriSpacingRole.xs),
        children: [
          if (group.role?.icon != null)
            CdnIcon(
              serverRole: group.role,
              size: sizing.dimen(NeriDimen.mentionIcon),
            ),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
          ),
          Text('— ${group.members.length}', style: style),
        ],
      ),
    );
  }
}

class _MemberRow extends ConsumerWidget {
  const _MemberRow({
    required this.serverId,
    required this.member,
    required this.online,
    required this.surface,
  });

  final String serverId;
  final ServerMember member;
  final bool online;
  final Color surface;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final user = ref.watch(usersProvider.select((u) => u[member.userId]));
    if (user == null) return const SizedBox.shrink();

    final hexColor = ref.watch(
      memberColorProvider((serverId: serverId, userId: member.userId)),
    );

    return Opacity(
      opacity: online ? 1 : _offlineOpacity,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: sizing.space(NeriSpacingRole.sm),
          vertical: sizing.space(NeriSpacingRole.xs),
        ),
        child: Row(
          spacing: sizing.space(NeriSpacingRole.md),
          children: [
            PresenceAvatar(
              user: user,
              size: sizing.dimen(NeriDimen.avatarMd),
              surface: surface,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildColoredName(
                    member.nickname ?? user.username,
                    hexColor: hexColor,
                    style: context.neriText[NeriTextRole.bodyLarge].copyWith(
                      color: colors[NeriToken.textSecondary],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (online) PresenceLine(userId: member.userId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
