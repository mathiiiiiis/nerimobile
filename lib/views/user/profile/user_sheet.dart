import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:nerimobile/models/friend.dart';
import 'package:nerimobile/models/server.dart';

import 'package:nerimobile/models/user.dart';
import 'package:nerimobile/models/user_details.dart';
import 'package:nerimobile/models/user_presence.dart';
import 'package:nerimobile/stores/channel/channel_store.dart';
import 'package:nerimobile/stores/server/server_member_store.dart';
import 'package:nerimobile/stores/server/server_store.dart';
import 'package:nerimobile/stores/toast/toast_store.dart';
import 'package:nerimobile/stores/user/friend_store.dart';
import 'package:nerimobile/stores/user/user_details_store.dart';
import 'package:nerimobile/stores/user/user_presence_store.dart';
import 'package:nerimobile/stores/user/user_store.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';
import 'package:nerimobile/utils/colors.dart';
import 'package:nerimobile/utils/date.dart';
import 'package:nerimobile/utils/format.dart';
import 'package:nerimobile/utils/url.dart';
import 'package:nerimobile/views/core/banner_image.dart';
import 'package:nerimobile/views/core/list/skeleton.dart';
import 'package:nerimobile/views/core/modal/bottom_sheet.dart';
import 'package:nerimobile/views/markup/markup.dart';
import 'package:nerimobile/views/user/activity_art.dart';
import 'package:nerimobile/views/user/avatar.dart';
import 'package:nerimobile/views/user/presence_line.dart';

const _bioSkeletonHeight = 48.0;
const _activityArtHeight = 64.0;
const _progressHeight = 4.0;
const _peekingCardWidth = 0.85;
const _nerimityLogo = 'assets/nerimity/logo.png';

Future<void> showUserSheet(
  BuildContext context, {
  required User user,
  String? channelId,
}) async {
  ProviderScope.containerOf(
    context,
    listen: false,
  ).invalidate(userDetailsProvider(user.id));

  final picked = await showSheet<SheetAction>(
    context,
    dragHandle: false,
    builder: (_) => _UserSheet(user: user, channelId: channelId),
  );
  picked?.onTap();
}

class _UserSheet extends ConsumerWidget {
  const _UserSheet({required this.user, this.channelId});

  final User user;
  final String? channelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sizing = context.neriSize;
    final user = ref.watch(userProvider(this.user.id)) ?? this.user;
    final details = ref.watch(userDetailsProvider(user.id));
    final presence = ref.watch(presencesProvider)[user.id];
    final activities = presence?.activities ?? const [];
    final bio = details.value?.bio?.trim();
    final joinedAt = details.value?.joinedAt;

    final serverId = ref.watch(
      channelsProvider.select((channels) => channels[channelId]?.serverId),
    );
    final server = ref.watch(
      serversProvider.select((servers) => servers[serverId]),
    );
    final memberJoinedAt = ref.watch(
      serverMembersProvider.select(
        (members) => members[serverId]?[user.id]?.joinedAt,
      ),
    );

    final member = switch (channelId) {
      final channelId? => (channelId: channelId, userId: user.id),
      null => null,
    };

    final style = _ProfileStyle.from(context, details.value);
    final radius = Radius.circular(sizing.radius(NeriRadiusRole.xl));

    return ClipRRect(
      borderRadius: BorderRadius.only(topLeft: radius, topRight: radius),
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: style.background),
        child: Theme(
          data: style.apply(Theme.of(context)),
          child: SheetActions(
            header: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: sizing.space(NeriSpacingRole.sm),
              children: [
                SheetHeader(
                  title:
                      (member == null
                          ? null
                          : ref.watch(channelMemberNicknameProvider(member))) ??
                      user.username,
                  titleColor: member == null
                      ? null
                      : ref.watch(channelMemberColorProvider(member)),
                  caption: _Caption(user: user, custom: presence?.custom),
                  leading: PresenceAvatar(
                    user: user,
                    size: sizing.dimen(NeriDimen.avatarMd),
                    surface: context.neri[NeriToken.border],
                  ),
                  background: BannerImage(
                    path: user.banner,
                    fallback: hexToColor(user.hexColor),
                  ),
                ),
                if (activities.isNotEmpty) _Activities(activities: activities),
                for (final card in [
                  if (details.isLoading && !details.hasValue)
                    const _Card(
                      child: SkeletonScope(
                        child: SkeletonBlock(height: _bioSkeletonHeight),
                      ),
                    )
                  else if (bio != null && bio.isNotEmpty)
                    _BioCard(bio: bio),
                  if (joinedAt != null)
                    _JoinedCard(
                      joinedAt: joinedAt,
                      server: server,
                      memberJoinedAt: memberJoinedAt,
                    ),
                ])
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: sizing.space(NeriSpacingRole.md),
                    ),
                    child: card,
                  ),
              ],
            ),
            groups: _actions(ref, user, details.value),
          ),
        ),
      ),
    );
  }
}

//TODO: add l10n
List<SheetGroup> _actions(WidgetRef ref, User user, UserDetails? details) {
  final toast = ref.read(toastProvider.notifier);
  void notAdded() => toast.show('Not added yet :/');
  final copyId = SheetGroup([
    SheetAction(
      icon: Symbols.id_card_rounded,
      label: 'Copy ID',
      dismiss: false,
      onTap: () => toast.copy(user.id, label: 'ID copied'),
    ),
  ]);
  if (user.id == ref.watch(currentUserIdProvider)) return [copyId];

  final friend = ref.watch(
    friendsProvider.select((friends) => friends[user.id]?.status),
  );
  final blocked = friend == FriendStatus.blocked;
  final unreachable = blocked || (details?.blockedYou ?? false);
  final following = details?.following ?? false;

  return [
    SheetGroup([
      switch (friend) {
        FriendStatus.friends => SheetAction(
          icon: Symbols.person_remove_rounded,
          label: 'Remove friend',
          dismiss: false,
          onTap: notAdded,
        ),
        FriendStatus.pending => SheetAction(
          icon: Symbols.person_add_rounded,
          label: 'Accept friend request',
          dismiss: false,
          onTap: notAdded,
        ),
        FriendStatus.sent => SheetAction(
          icon: Symbols.close_rounded,
          label: 'Pending request',
          enabled: !unreachable,
          dismiss: false,
          onTap: notAdded,
        ),
        _ => SheetAction(
          icon: Symbols.person_add_rounded,
          label: 'Add friend',
          enabled: !unreachable,
          dismiss: false,
          onTap: notAdded,
        ),
      },
      SheetAction(
        icon: following
            ? Symbols.remove_circle_rounded
            : Symbols.add_circle_rounded,
        label: following ? 'Unfollow' : 'Follow',
        enabled: details != null && !unreachable,
        dismiss: false,
        onTap: notAdded,
      ),
    ]),
    copyId,
    SheetGroup([
      SheetAction(
        icon: Symbols.block_rounded,
        label: blocked ? 'Unblock' : 'Block',
        destructive: !blocked,
        dismiss: false,
        onTap: notAdded,
      ),
    ]),
  ];
}

class _ProfileStyle {
  const _ProfileStyle({
    required this.background,
    required this.panel,
    required this.accent,
  });

  final Gradient background;
  final Color panel;
  final Color accent;

  ThemeData apply(ThemeData theme) {
    final colors = theme.extension<NeriColors>()!;
    return theme.copyWith(
      colorScheme: theme.colorScheme.copyWith(primary: accent),
      extensions: [
        ...theme.extensions.values.where((e) => e is! NeriColors),
        colors.copyWith(
          colors: {
            ...colors.colors,
            NeriToken.primary: accent,
            NeriToken.cardBright: panel,
          },
        ),
      ],
    );
  }

  //single set == whole bg
  factory _ProfileStyle.from(BuildContext context, UserDetails? details) {
    final colors = context.neri;
    final one = _parse(details?.bgColorOne);
    final two = _parse(details?.bgColorTwo);
    final top = one ?? two ?? colors[NeriToken.pane];
    final bottom = two ?? one ?? colors[NeriToken.pane];

    return _ProfileStyle(
      background: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [top, bottom],
      ),
      panel: profilePanelColor(top, bottom),
      accent: _parse(details?.primaryColor) ?? colors[NeriToken.primary],
    );
  }
}

Color? _parse(String? hex) {
  if (hex == null || hex.isEmpty) return null;
  try {
    return parseHexColor(hex);
  } on FormatException {
    return null;
  }
}

class _Caption extends StatelessWidget {
  const _Caption({required this.user, required this.custom});

  final User user;
  final String? custom;

  @override
  Widget build(BuildContext context) {
    final custom = this.custom;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('${user.username}:${user.tag}'),
        if (custom != null && custom.isNotEmpty)
          MarkupView(
            rawText: singleLine(custom),
            inline: true,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final sizing = context.neriSize;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.neri[NeriToken.cardBright],
        borderRadius: sizing.rounded(NeriRadiusRole.lg),
      ),
      child: Padding(
        padding: EdgeInsets.all(sizing.space(NeriSpacingRole.md)),
        child: child,
      ),
    );
  }
}

class _Activities extends StatelessWidget {
  const _Activities({required this.activities});

  final List<ActivityStatus> activities;

  @override
  Widget build(BuildContext context) {
    final sizing = context.neriSize;
    final inset = sizing.space(NeriSpacingRole.md);

    if (activities.length == 1) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: inset),
        child: _ActivityCard(activity: activities.single),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - inset * 2) * _peekingCardWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: inset),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: sizing.space(NeriSpacingRole.sm),
              children: [
                for (final activity in activities)
                  SizedBox(
                    width: width,
                    child: _ActivityCard(activity: activity),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ActivityCard extends StatefulWidget {
  const _ActivityCard({required this.activity});

  final ActivityStatus activity;

  @override
  State<_ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<_ActivityCard> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _syncTick();
  }

  @override
  void didUpdateWidget(_ActivityCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncTick();
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  void _syncTick() {
    if (widget.activity.startedAt == null) {
      _tick?.cancel();
      _tick = null;
      return;
    }
    _tick ??= Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final text = context.neriText;
    final activity = widget.activity;
    final kind = activityKindOf(activity);
    final rich =
        activity.imgSrc != null ||
        activity.emoji != null ||
        activity.title != null ||
        activity.subtitle != null;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: sizing.space(NeriSpacingRole.sm),
        children: [
          Row(
            spacing: sizing.space(NeriSpacingRole.xs),
            children: [
              Icon(
                kind.icon,
                fill: 1,
                size: sizing.dimen(NeriDimen.iconSm) * 0.6,
                color: context.neri[NeriToken.primary],
              ),
              Flexible(
                child: Text(
                  '${activity.action} ${activity.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text[NeriTextRole.labelLarge].copyWith(
                    color: context.neri[NeriToken.primary],
                  ),
                ),
              ),
            ],
          ),
          if (rich)
            Row(
              spacing: sizing.space(NeriSpacingRole.md),
              children: [
                ActivityArt(activity: activity, height: _activityArtHeight),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _Line(
                        text: activity.title ?? activity.name,
                        role: NeriTextRole.bodyMedium,
                        color: colors[NeriToken.text],
                        link: activity.link,
                      ),
                      if (activity.subtitle case final subtitle?)
                        _Line(
                          text: subtitle,
                          role: NeriTextRole.bodySmall,
                          color: colors[NeriToken.textSecondary],
                        ),
                      _Elapsed(activity: activity),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({
    required this.text,
    required this.role,
    required this.color,
    this.link,
  });

  final String text;
  final NeriTextRole role;
  final Color color;
  final String? link;

  @override
  Widget build(BuildContext context) {
    final link = this.link;
    final line = DefaultTextStyle(
      style: context.neriText[role].copyWith(color: color),
      child: MarkupView(
        rawText: singleLine(text),
        inline: true,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
    if (link == null) return line;

    return GestureDetector(onTap: () => openExternal(link), child: line);
  }
}

class _Elapsed extends StatelessWidget {
  const _Elapsed({required this.activity});

  final ActivityStatus activity;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final elapsed = activity.elapsedAt(DateTime.now());
    if (elapsed == null) return const SizedBox.shrink();

    final style = context.neriText[NeriTextRole.bodySmall].copyWith(
      color: colors[NeriToken.textSecondary],
    );
    final length = activity.length;
    final media = activityKindOf(activity) != ActivityKind.game;

    if (!media || length == null || length <= Duration.zero) {
      return Text(formatRemaining(elapsed, units: 2), style: style);
    }

    final shown = elapsed > length ? length : elapsed;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: sizing.space(NeriSpacingRole.xs),
      children: [
        Padding(
          padding: EdgeInsets.only(top: sizing.space(NeriSpacingRole.xs)),
          child: _Progress(value: shown.inMilliseconds / length.inMilliseconds),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(formatDuration(shown), style: style),
            Text(formatDuration(length), style: style),
          ],
        ),
      ],
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final radius = context.neriSize.rounded(NeriRadiusRole.sm);

    return Container(
      height: _progressHeight,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: colors[NeriToken.border],
        borderRadius: radius,
      ),
      child: FractionallySizedBox(
        widthFactor: value,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors[NeriToken.primary],
            borderRadius: radius,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _BioCard extends StatelessWidget {
  const _BioCard({required this.bio});

  final String bio;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final text = context.neriText;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: context.neriSize.space(NeriSpacingRole.xs),
        children: [
          DefaultTextStyle(
            style: text[NeriTextRole.bodyMedium].copyWith(
              color: colors[NeriToken.textSecondary],
            ),
            child: MarkupView(rawText: bio),
          ),
        ],
      ),
    );
  }
}

class _JoinedCard extends StatelessWidget {
  const _JoinedCard({
    required this.joinedAt,
    required this.server,
    required this.memberJoinedAt,
  });

  final int joinedAt;
  final Server? server;
  final int? memberJoinedAt;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final icon = sizing.dimen(NeriDimen.avatarXs);
    final server = this.server;
    final memberJoinedAt = this.memberJoinedAt;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: sizing.space(NeriSpacingRole.xs),
        children: [
          Text(
            'Joined at', //TODO: add l10n
            style: context.neriText[NeriTextRole.labelSmall].copyWith(
              color: colors[NeriToken.textSecondary],
            ),
          ),
          Wrap(
            spacing: sizing.space(NeriSpacingRole.lg),
            runSpacing: sizing.space(NeriSpacingRole.xs),
            children: [
              _JoinedDate(
                icon: ClipRRect(
                  borderRadius: sizing.rounded(NeriRadiusRole.sm),
                  child: Image.asset(_nerimityLogo, width: icon, height: icon),
                ),
                at: joinedAt,
              ),
              if (server != null && memberJoinedAt != null)
                _JoinedDate(
                  icon: Avatar(
                    server: server,
                    size: icon,
                    borderRadius: sizing.rounded(NeriRadiusRole.sm),
                  ),
                  at: memberJoinedAt,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _JoinedDate extends StatelessWidget {
  const _JoinedDate({required this.icon, required this.at});

  final Widget icon;
  final int at;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: context.neriSize.space(NeriSpacingRole.sm),
      children: [
        icon,
        Text(
          formatTimestamp(at),
          style: context.neriText[NeriTextRole.bodyMedium].copyWith(
            color: context.neri[NeriToken.text],
          ),
        ),
      ],
    );
  }
}
