import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:nerimobile/db/cache_hydration.dart';

import 'package:nerimobile/models/channel.dart';
import 'package:nerimobile/stores/channel/channel_store.dart';
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
import 'package:nerimobile/views/mention_badge.dart';
import 'package:nerimobile/views/server/channel_list_skeleton.dart';
import 'package:nerimobile/views/shell/widgets/scroll_fade.dart';

class ChannelListPane extends ConsumerWidget {
  const ChannelListPane({
    super.key,
    required this.serverId,
    this.selectedChannelId,
  });

  final String serverId;
  final String? selectedChannelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final name = ref.watch(serversProvider.select((s) => s[serverId]?.name));
    final groups = ref.watch(serverChannelGroupsProvider(serverId));
    final unknown =
        groups.isEmpty && ref.watch(cacheHydrationProvider).isLoading;
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
                      for (final (:category, :channels) in groups) ...[
                        if (category != null) _CategoryHeader(category),
                        for (final channel in channels)
                          _ChannelRow(
                            channel: channel,
                            selected: channel.id == selectedChannelId,
                          ),
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
}

class _CategoryHeader extends ConsumerWidget {
  const _CategoryHeader(this.category);

  final Channel category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.neri;
    final sizing = context.neriSize;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        sizing.space(NeriSpacingRole.md),
        sizing.space(NeriSpacingRole.md),
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
          ],
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

    return Padding(
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
                  child: CdnIcon(
                    channel: channel,
                    size: sizing.dimen(NeriDimen.emojiSm),
                    fallbackIcon: Symbols.tag_rounded,
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
  }
}
