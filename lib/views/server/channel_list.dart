import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:nerimobile/db/cache_hydration.dart';

import 'package:nerimobile/models/channel.dart';
import 'package:nerimobile/stores/channel/channel_store.dart';
import 'package:nerimobile/stores/channel/last_opened_store.dart';
import 'package:nerimobile/stores/connection/connection_store.dart';
import 'package:nerimobile/stores/server/server_channel_list.dart';
import 'package:nerimobile/stores/server/server_permissions.dart';
import 'package:nerimobile/stores/server/server_store.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/border.dart';
import 'package:nerimobile/theme/sizing/breakpoints.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';
import 'package:nerimobile/views/cdn_icon.dart';
import 'package:nerimobile/views/collapse.dart';
import 'package:nerimobile/views/mention_badge.dart';
import 'package:nerimobile/views/server/channel_list_skeleton.dart';
import 'package:nerimobile/views/shell/widgets/scroll_fade.dart';

const _unreadMotion = Duration(milliseconds: 200);

final collapsedCategoriesProvider =
    NotifierProvider<CollapsedCategories, Set<String>>(CollapsedCategories.new);

class CollapsedCategories extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  void toggle(String categoryId) => state = state.contains(categoryId)
      ? state.difference({categoryId})
      : {...state, categoryId};
}

class ChannelListPane extends ConsumerStatefulWidget {
  const ChannelListPane({
    super.key,
    required this.serverId,
    this.selectedChannelId,
  });

  final String serverId;
  final String? selectedChannelId;

  @override
  ConsumerState<ChannelListPane> createState() => _ChannelListPaneState();
}

class _ChannelListPaneState extends ConsumerState<ChannelListPane>
    with CollapseSettling<ChannelListPane> {
  void _toggle(String categoryId, {required bool opening}) {
    ref.read(collapsedCategoriesProvider.notifier).toggle(categoryId);
    settle(categoryId, opening: opening);
  }

  @override
  Widget build(BuildContext context) {
    final serverId = widget.serverId;
    final selectedChannelId =
        widget.selectedChannelId ??
        ref.watch(serverChannelToOpenProvider(serverId));
    final colors = context.neri;
    final sizing = context.neriSize;
    final name = ref.watch(serversProvider.select((s) => s[serverId]?.name));
    final groups = ref.watch(serverChannelGroupsProvider(serverId));
    final unknown =
        groups.isEmpty &&
        (ref.watch(cacheHydrationProvider).isLoading ||
            ref.watch(connectionProvider) is! Authenticated);
    final collapsed = ref.watch(collapsedCategoriesProvider);
    final notifications = ref.watch(channelNotificationsProvider);
    final framed = NeriWindow.of(context).isDualPane;
    final surface = framed
        ? colors[NeriToken.background]
        : colors[NeriToken.pane];

    final list = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.all(sizing.space(NeriSpacingRole.md)),
          child: Text(
            name ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.neriText[NeriTextRole.headlineSmall].copyWith(
              color: colors[NeriToken.text],
            ),
          ),
        ),
        Expanded(
          child: ScrollFade(
            color: surface,
            child: unknown
                ? const ChannelListSkeleton()
                : ListView(
                    padding: EdgeInsets.only(
                      bottom: sizing.dimen(NeriDimen.fadeHeight),
                    ),
                    children: [
                      for (final (index, (:category, :channels))
                          in groups.indexed)
                        if (category == null)
                          for (final channel in channels)
                            _ChannelRow(
                              channel: channel,
                              selected: channel.id == selectedChannelId,
                            )
                        else ...[
                          if (index > 0)
                            SizedBox(height: sizing.space(NeriSpacingRole.sm)),
                          ..._category(
                            category,
                            channels,
                            folded: collapsed.contains(category.id),
                            selectedChannelId: selectedChannelId,
                            notifications: notifications,
                          ),
                          SizedBox(height: sizing.space(NeriSpacingRole.sm)),
                        ],
                    ],
                  ),
          ),
        ),
      ],
    );

    if (!framed) return list;

    return Padding(
      padding: EdgeInsets.all(sizing.space(NeriSpacingRole.sm)),
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: sizing.rounded(NeriRadiusRole.md),
          border: Border.all(
            color: colors[NeriToken.border],
            width: sizing.border(NeriBorderRole.hairline),
          ),
        ),
        child: list,
      ),
    );
  }

  Iterable<Widget> _category(
    Channel category,
    List<Channel> channels, {
    required bool folded,
    required String? selectedChannelId,
    required Map<String, int> notifications,
  }) sync* {
    yield _CategoryHeader(
      category,
      collapsed: folded,
      onTap: () => _toggle(category.id, opening: folded),
    );

    for (final channel in channels) {
      final selected = channel.id == selectedChannelId;
      //folded keep unread channels in sight
      final open = !folded || selected || notifications.containsKey(channel.id);
      if (!open && settling(category.id) != false) continue;

      yield CollapseReveal(
        key: ValueKey(channel.id),
        open: open,
        appear: settling(category.id) == true,
        child: _ChannelRow(channel: channel, selected: selected),
      );
    }
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader(
    this.category, {
    required this.collapsed,
    required this.onTap,
  });

  final Channel category;
  final bool collapsed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          sizing.space(NeriSpacingRole.md),
          sizing.space(NeriSpacingRole.sm),
          sizing.space(NeriSpacingRole.md),
          sizing.space(NeriSpacingRole.xs),
        ),
        child: IconTheme.merge(
          data: IconThemeData(color: colors[NeriToken.textTertiary]),
          child: Row(
            spacing: sizing.space(NeriSpacingRole.xs),
            children: [
              CdnIcon(
                channel: category,
                size: sizing.dimen(NeriDimen.mentionIcon),
                fallbackIcon: Symbols.segment_rounded,
              ),
              Expanded(
                child: Text(
                  category.name ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.neriText[NeriTextRole.labelSmall].copyWith(
                    color: context.neri[NeriToken.textTertiary],
                  ),
                ),
              ),
              CollapseChevron(
                collapsed: collapsed,
                size: sizing.dimen(NeriDimen.iconSm),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChannelRow extends ConsumerWidget {
  const _ChannelRow({required this.channel, required this.selected});

  final Channel channel;
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final notification = ref.watch(
      channelNotificationsProvider.select((n) => n[channel.id]),
    );
    final highlighted = selected || notification != null;
    final private = ref.watch(
      serversProvider.select((servers) {
        final server = servers[channel.serverId];
        return server != null && isPrivateChannel(server, channel);
      }),
    );

    final row = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: sizing.space(NeriSpacingRole.sm),
      ),
      child: Material(
        color: selected
            ? colors[NeriToken.drawerItemHoverBackground]
            : Colors.transparent,
        borderRadius: sizing.rounded(NeriRadiusRole.md),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () =>
              context.go('/app/servers/${channel.serverId}/${channel.id}'),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: sizing.space(NeriSpacingRole.sm),
              vertical: sizing.space(NeriSpacingRole.sm),
            ),
            child: Row(
              spacing: sizing.space(NeriSpacingRole.sm),
              children: [
                IconTheme.merge(
                  data: IconThemeData(
                    color:
                        colors[highlighted
                            ? NeriToken.text
                            : NeriToken.textTertiary],
                  ),
                  child: _IconBox(
                    child: CdnIcon(
                      channel: channel,
                      size: sizing.dimen(NeriDimen.emojiSm),
                      fallbackIcon: Symbols.tag_rounded,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    channel.name ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.neriText[NeriTextRole.bodyLarge].copyWith(
                      color:
                          colors[highlighted
                              ? NeriToken.text
                              : NeriToken.textSecondary],
                      fontWeight: notification != null ? FontWeight.w600 : null,
                    ),
                  ),
                ),
                if (private)
                  Icon(
                    Symbols.lock_rounded,
                    size: sizing.dimen(NeriDimen.mentionAvatar),
                    fill: 1,
                    color: colors[NeriToken.textTertiary],
                  ),
                if (notification != null && notification > 0)
                  MentionBadge(count: notification),
              ],
            ),
          ),
        ),
      ),
    );

    return Stack(
      children: [
        row,
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: Center(
            child: _UnreadDot(visible: notification != null && !selected),
          ),
        ),
      ],
    );
  }
}

class _UnreadDot extends StatelessWidget {
  const _UnreadDot({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    final sizing = context.neriSize;
    final radius = Radius.circular(sizing.radius(NeriRadiusRole.full));

    return AnimatedContainer(
      duration: _unreadMotion,
      curve: Curves.easeOut,
      width: sizing.space(NeriSpacingRole.xs),
      height: visible ? sizing.space(NeriSpacingRole.sm) : 0,
      decoration: BoxDecoration(
        color: context.neri[NeriToken.unreadDot],
        borderRadius: BorderRadius.only(topRight: radius, bottomRight: radius),
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final sizing = context.neriSize;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.neri[NeriToken.surfaceHover],
        borderRadius: sizing.rounded(NeriRadiusRole.sm),
      ),
      child: Padding(
        padding: EdgeInsets.all(sizing.space(NeriSpacingRole.xs)),
        child: child,
      ),
    );
  }
}
