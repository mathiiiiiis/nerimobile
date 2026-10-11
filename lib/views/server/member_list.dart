import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import 'package:nerimobile/models/server_member.dart';
import 'package:nerimobile/stores/channel/channel_notice_store.dart';
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
import 'package:nerimobile/utils/caches.dart';
import 'package:nerimobile/utils/colors.dart';
import 'package:nerimobile/utils/image.dart';
import 'package:nerimobile/views/avatar.dart';
import 'package:nerimobile/views/cdn_icon.dart';
import 'package:nerimobile/views/chat/channel/channel_header.dart';
import 'package:nerimobile/views/dashboard/widget/dm_list_skeleton.dart';
import 'package:nerimobile/views/empty_state.dart';
import 'package:nerimobile/views/markup/markup.dart';
import 'package:nerimobile/views/presence/presence_line.dart';
import 'package:nerimobile/views/shell/widgets/scroll_fade.dart';

const _offlineOpacity = 0.5;
const _bannerAspectRatio = 30 / 12;
const _collapseMotion = Duration(milliseconds: 200);

final membersPaneOpenProvider = NotifierProvider<MembersPaneOpen, bool>(
  MembersPaneOpen.new,
);

class MembersPaneOpen extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() => state = !state;
}

final collapsedMemberGroupsProvider =
    NotifierProvider<CollapsedMemberGroups, Map<String, Set<String>>>(
      CollapsedMemberGroups.new,
    );

class CollapsedMemberGroups extends Notifier<Map<String, Set<String>>> {
  @override
  Map<String, Set<String>> build() => const {};

  void toggle(String serverId, String groupKey) {
    final current = state[serverId] ?? const {};
    state = {
      ...state,
      serverId: current.contains(groupKey)
          ? current.difference({groupKey})
          : {...current, groupKey},
    };
  }
}

extension on MemberGroup {
  String get key => role?.id ?? (online ? 'online' : 'offline');
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

class MemberList extends ConsumerStatefulWidget {
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
  ConsumerState<MemberList> createState() => _MemberListState();
}

class _MemberListState extends ConsumerState<MemberList> {
  //true during open, false while close
  final _settling = <String, bool>{};
  final _settleTimers = <String, Timer>{};

  @override
  void dispose() {
    for (final timer in _settleTimers.values) {
      timer.cancel();
    }
    super.dispose();
  }

  void _toggle(String groupKey, {required bool opening}) {
    ref
        .read(collapsedMemberGroupsProvider.notifier)
        .toggle(widget.serverId, groupKey);

    _settleTimers[groupKey]?.cancel();
    _settleTimers[groupKey] = Timer(_collapseMotion, () {
      if (mounted) setState(() => _settling.remove(groupKey));
    });
    setState(() => _settling[groupKey] = opening);
  }

  @override
  Widget build(BuildContext context) {
    final serverId = widget.serverId;
    final channelId = widget.channelId;
    final surface = widget.surface;
    final sizing = context.neriSize;
    final groups = ref.watch(
      memberGroupsProvider((serverId: serverId, channelId: channelId)),
    );
    final unknown =
        ref.watch(connectionProvider) is! Authenticated &&
        (ref.watch(serverMembersProvider)[serverId]?.length ?? 0) <= 1;
    final collapsed = ref.watch(
      collapsedMemberGroupsProvider.select((c) => c[serverId] ?? const {}),
    );
    final total = groups.fold(0, (sum, group) => sum + group.members.length);
    final entries = [
      for (final group in groups) ...[
        (group: group, member: null),
        if (!collapsed.contains(group.key) || _settling[group.key] == false)
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
              itemCount: entries.length + _headerCount,
              itemBuilder: (context, index) {
                switch (index) {
                  case 0:
                    return _ServerBanner(serverId);
                  case 1:
                    return _ChannelNotice(channelId);
                  case 2:
                    return _MemberCount(total);
                }

                final (:group, :member) = entries[index - _headerCount];
                final open = !collapsed.contains(group.key);
                return member == null
                    ? _GroupHeader(
                        group,
                        collapsed: !open,
                        onTap: () => _toggle(group.key, opening: !open),
                      )
                    : _Reveal(
                        key: ValueKey((group.key, member.userId)),
                        open: open,
                        appear: _settling[group.key] == true,
                        child: _MemberRow(
                          serverId: serverId,
                          member: member,
                          online: group.online,
                          surface: surface,
                        ),
                      );
              },
            ),
    );
  }
}

const _headerCount = 3;

class _Reveal extends StatelessWidget {
  const _Reveal({
    super.key,
    required this.open,
    required this.appear,
    required this.child,
  });

  final bool open;
  final bool appear;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: appear ? 0 : 1, end: open ? 1 : 0),
      duration: _collapseMotion,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => ClipRect(
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: value,
          child: Opacity(opacity: value, child: child),
        ),
      ),
      child: child,
    );
  }
}

class _ServerBanner extends ConsumerWidget {
  const _ServerBanner(this.serverId);

  final String serverId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final server = ref.watch(serversProvider.select((s) => s[serverId]));
    final banner = server?.banner;
    if (server == null || banner == null || banner.isEmpty) {
      return const SizedBox.shrink();
    }

    final sizing = context.neriSize;
    final placeholder = ColoredBox(color: hexToColor(server.hexColor));

    return Padding(
      padding: EdgeInsets.fromLTRB(
        sizing.space(NeriSpacingRole.md),
        0,
        sizing.space(NeriSpacingRole.md),
        sizing.space(NeriSpacingRole.md),
      ),
      child: ClipRRect(
        borderRadius: sizing.rounded(NeriRadiusRole.md),
        child: AspectRatio(
          aspectRatio: _bannerAspectRatio,
          child: LayoutBuilder(
            builder: (context, constraints) => CachedNetworkImage(
              imageUrl: buildImageUrl(
                banner,
                size:
                    (constraints.maxWidth *
                            MediaQuery.devicePixelRatioOf(context))
                        .round(),
              ),
              cacheManager: mediaCache,
              fit: BoxFit.cover,
              fadeInDuration: Duration.zero,
              fadeOutDuration: Duration.zero,
              placeholder: (_, _) => placeholder,
              errorWidget: (_, _, _) => placeholder,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChannelNotice extends ConsumerWidget {
  const _ChannelNotice(this.channelId);

  final String channelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notice = ref.watch(channelNoticeProvider(channelId)).value;
    if (notice == null || notice.isEmpty) return const SizedBox.shrink();

    final colors = context.neri;
    final sizing = context.neriSize;
    final text = context.neriText;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        sizing.space(NeriSpacingRole.md),
        0,
        sizing.space(NeriSpacingRole.md),
        sizing.space(NeriSpacingRole.md),
      ),
      child: Container(
        padding: EdgeInsets.all(sizing.space(NeriSpacingRole.md)),
        decoration: BoxDecoration(
          color: colors[NeriToken.card],
          borderRadius: sizing.rounded(NeriRadiusRole.md),
          border: Border.all(
            color: colors[NeriToken.border],
            width: sizing.border(NeriBorderRole.hairline),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: sizing.space(NeriSpacingRole.sm),
          children: [
            Row(
              spacing: sizing.space(NeriSpacingRole.xs),
              children: [
                Icon(
                  Symbols.info_rounded,
                  size: sizing.dimen(NeriDimen.iconSm),
                  color: colors[NeriToken.primary],
                ),
                Text(
                  'Channel Notice', //TODO: add l10n
                  style: text[NeriTextRole.labelLarge].copyWith(
                    color: colors[NeriToken.text],
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            DefaultTextStyle(
              style: text[NeriTextRole.labelLarge].copyWith(
                color: colors[NeriToken.text],
              ),
              child: MarkupView(rawText: notice, inline: true),
            ),
          ],
        ),
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
  const _GroupHeader(
    this.group, {
    required this.collapsed,
    required this.onTap,
  });

  final MemberGroup group;
  final bool collapsed;
  final VoidCallback onTap;

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

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          sizing.space(NeriSpacingRole.md),
          sizing.space(NeriSpacingRole.md),
          sizing.space(NeriSpacingRole.md),
          sizing.space(NeriSpacingRole.xs),
        ),
        child: Row(
          spacing: sizing.space(NeriSpacingRole.xs),
          children: [
            Expanded(
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
            ),
            AnimatedRotation(
              turns: collapsed ? -0.25 : 0,
              duration: _collapseMotion,
              child: Icon(
                Symbols.keyboard_arrow_down_rounded,
                size: sizing.dimen(NeriDimen.iconSm),
                color: style.color,
              ),
            ),
          ],
        ),
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
