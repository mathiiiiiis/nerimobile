import 'package:nerimobile/models/channel.dart';
import 'package:nerimobile/models/user.dart';
import 'package:nerimobile/stores/channel/channel_store.dart';
import 'package:nerimobile/stores/server/server_store.dart';
import 'package:nerimobile/theme/sizing/border.dart';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:nerimobile/stores/inbox/inbox_store.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/breakpoints.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';
import 'package:nerimobile/views/avatar.dart';
import 'package:nerimobile/views/cdn_icon.dart';
import 'package:nerimobile/views/presence/presence_line.dart';

//mached composer inset on dual pane
double _headerInset(BuildContext context) => context.neriSize.space(
  NeriWindow.of(context).isDualPane ? NeriSpacingRole.sm : NeriSpacingRole.md,
);

//space covered by header
double channelHeaderExtent(BuildContext context) =>
    context.neriSize.dimen(NeriDimen.channelHeaderHeight) +
    _headerInset(context) * 2;

class ChannelHeader extends ConsumerWidget {
  const ChannelHeader({
    super.key,
    required this.channelId,
    this.showBack = false,
    this.actions = const [],
  });

  final String channelId;
  final bool showBack;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final recipient = ref.watch(inboxProvider)[channelId]?.recipient;
    final channel = ref.watch(channelsProvider.select((c) => c[channelId]));
    final radius = sizing.rounded(NeriRadiusRole.image);

    return Padding(
      padding: EdgeInsets.all(_headerInset(context)),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            height: sizing.dimen(NeriDimen.channelHeaderHeight),
            padding: EdgeInsets.only(
              left: sizing.space(NeriSpacingRole.sm),
              right: sizing.space(NeriSpacingRole.md),
            ),
            decoration: BoxDecoration(
              color: colors[NeriToken.header],
              borderRadius: radius,
              border: Border.all(
                color: colors[NeriToken.border],
                width: sizing.border(NeriBorderRole.hairline),
              ),
            ),
            child: Row(
              children: [
                if (showBack)
                  HeaderIconButton(
                    icon: Symbols.arrow_back_rounded,
                    onTap: () =>
                        context.canPop() ? context.pop() : context.go('/app'),
                  ),
                if (recipient != null)
                  ..._recipient(context, recipient)
                else if (channel?.serverId != null)
                  ..._serverChannel(context, channel!),
                ...actions,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

List<Widget> _recipient(BuildContext context, User recipient) {
  final colors = context.neri;
  final sizing = context.neriSize;

  return [
    PresenceAvatar(
      user: recipient,
      size: sizing.dimen(NeriDimen.controlSize),
      surface: colors[NeriToken.pane],
    ),
    SizedBox(width: sizing.space(NeriSpacingRole.md)),
    Expanded(
      child: _Titles(
        title: recipient.username,
        subtitle: PresenceLine(userId: recipient.id),
      ),
    ),
  ];
}

List<Widget> _serverChannel(BuildContext context, Channel channel) {
  final colors = context.neri;
  final sizing = context.neriSize;
  final size = sizing.dimen(NeriDimen.controlSize);

  return [
    SizedBox.square(
      dimension: size,
      child: Center(
        child: IconTheme.merge(
          data: IconThemeData(color: colors[NeriToken.textSecondary]),
          child: CdnIcon(
            channel: channel,
            size: sizing.dimen(NeriDimen.iconSm),
            fallbackIcon: Symbols.tag_rounded,
          ),
        ),
      ),
    ),
    SizedBox(width: sizing.space(NeriSpacingRole.md)),
    Expanded(
      child: _Titles(
        title: channel.name ?? '',
        subtitle: _ServerName(serverId: channel.serverId!),
      ),
    ),
  ];
}

class _Titles extends StatelessWidget {
  const _Titles({required this.title, required this.subtitle});

  final String title;
  final Widget subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.neriText[NeriTextRole.bodyLarge].copyWith(
            color: context.neri[NeriToken.text],
          ),
        ),
        subtitle,
      ],
    );
  }
}

class _ServerName extends ConsumerWidget {
  const _ServerName({required this.serverId});

  final String serverId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(serversProvider.select((s) => s[serverId]?.name));

    return Text(
      name ?? '',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: context.neriText[NeriTextRole.bodySmall].copyWith(
        color: context.neri[NeriToken.textPlaceholder],
      ),
    );
  }
}

class HeaderIconButton extends StatelessWidget {
  const HeaderIconButton({super.key, required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sizing = context.neriSize;
    final size = sizing.dimen(NeriDimen.controlSize);

    return InkWell(
      onTap: onTap,
      borderRadius: sizing.rounded(NeriRadiusRole.full),
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(
          icon,
          size: sizing.dimen(NeriDimen.iconSm),
          color: context.neri[NeriToken.textSecondary],
        ),
      ),
    );
  }
}
