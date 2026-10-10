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
import 'package:nerimobile/theme/sizing/border.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';
import 'package:nerimobile/utils/colors.dart';
import 'package:nerimobile/views/avatar.dart';
import 'package:nerimobile/views/cdn_icon.dart';
import 'package:nerimobile/views/chat/channel/channel_header.dart';
import 'package:nerimobile/views/dashboard/widget/dm_list_skeleton.dart';
import 'package:nerimobile/views/empty_state.dart';
import 'package:nerimobile/views/presence/presence_line.dart';
import 'package:nerimobile/views/shell/widgets/scroll_fade.dart';

const _offlineOpacity = 0.5;

final membersPaneOpenProvider = NotifierProvider<MembersPaneOpen, bool>(
  MembersPaneOpen.new,
);

class MembersPaneOpen extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() => state = !state;
}

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

    return ColoredBox(
      color: colors[NeriToken.background],
      child: SafeArea(
        bottom: false,
        child: ChannelInfo(
          serverId: serverId,
          channelId: channelId,
          surface: colors[NeriToken.background],
          leading: HeaderIconButton(
            icon: Symbols.arrow_back_rounded,
            onTap: () => context.canPop()
                ? context.pop()
                : context.go('/app/servers/$serverId/$channelId'),
          ),
        ),
      ),
    );
  }
}

class MembersPane extends StatelessWidget {
  const MembersPane({
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

    return Padding(
      padding: EdgeInsets.only(
        top: sizing.space(NeriSpacingRole.sm),
        right: sizing.space(NeriSpacingRole.sm),
        bottom: sizing.space(NeriSpacingRole.sm),
      ),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colors[NeriToken.background],
          borderRadius: sizing.rounded(NeriRadiusRole.md),
          border: Border.all(
            color: colors[NeriToken.border],
            width: sizing.border(NeriBorderRole.hairline),
          ),
        ),
        child: ChannelInfo(
          serverId: serverId,
          channelId: channelId,
          surface: colors[NeriToken.background],
        ),
      ),
    );
  }
}

enum _InfoTab {
  //TODO: add l10n
  info('Info', Symbols.info_rounded),
  files('Files', Symbols.folder_rounded),
  search('Search', Symbols.search_rounded);

  const _InfoTab(this.label, this.icon);

  final String label;
  final IconData icon;
}

class ChannelInfo extends StatefulWidget {
  const ChannelInfo({
    super.key,
    required this.serverId,
    required this.channelId,
    required this.surface,
    this.leading,
  });

  final String serverId;
  final String channelId;
  final Color surface;
  final Widget? leading;

  @override
  State<ChannelInfo> createState() => _ChannelInfoState();
}

class _ChannelInfoState extends State<ChannelInfo> {
  var _tab = _InfoTab.info;

  @override
  Widget build(BuildContext context) {
    final sizing = context.neriSize;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.all(sizing.space(NeriSpacingRole.md)),
          child: Row(
            spacing: sizing.space(NeriSpacingRole.sm),
            children: [
              ?widget.leading,
              for (final tab in _InfoTab.values)
                Expanded(
                  child: _TabButton(
                    tab: tab,
                    selected: tab == _tab,
                    onTap: () => setState(() => _tab = tab),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: switch (_tab) {
            _InfoTab.info => MemberList(
              serverId: widget.serverId,
              channelId: widget.channelId,
              surface: widget.surface,
            ),
            _InfoTab.files => const _NotAvailable(
              message: 'Files are not available yet', //TODO: add l10n
              icon: Symbols.folder_rounded,
            ),
            _InfoTab.search => const _NotAvailable(
              message: 'Search is not available yet', //TODO: add l10n
              icon: Symbols.search_rounded,
            ),
          },
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final _InfoTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final color = colors[selected ? NeriToken.text : NeriToken.textSecondary];

    return Material(
      color: selected ? colors[NeriToken.navIndicator] : Colors.transparent,
      borderRadius: sizing.rounded(NeriRadiusRole.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: sizing.space(NeriSpacingRole.sm),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: sizing.space(NeriSpacingRole.xs),
            children: [
              Icon(
                tab.icon,
                size: sizing.dimen(NeriDimen.iconSm),
                color: color,
              ),
              Flexible(
                child: Text(
                  tab.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.neriText[NeriTextRole.labelLarge].copyWith(
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotAvailable extends StatelessWidget {
  const _NotAvailable({required this.message, required this.icon});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.neriSize.space(NeriSpacingRole.md)),
      child: Align(
        alignment: Alignment.topCenter,
        child: EmptyState(message: message, icon: icon),
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
    final total = groups.fold(0, (sum, group) => sum + group.members.length);
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
              itemCount: entries.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) return _MemberCount(total);

                final (:group, :member) = entries[index - 1];
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

class _MemberCount extends StatelessWidget {
  const _MemberCount(this.count);

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final style = context.neriText[NeriTextRole.headlineSmall];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: sizing.space(NeriSpacingRole.md),
      ),
      child: Row(
        spacing: sizing.space(NeriSpacingRole.xs),
        children: [
          Text(
            'Members', //TODO: add l10n
            style: style.copyWith(color: colors[NeriToken.text]),
          ),
          Text(
            '($count)',
            style: style.copyWith(color: colors[NeriToken.textTertiary]),
          ),
        ],
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
