import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nerimobile/db/cache_hydration.dart';
import 'package:nerimobile/models/server.dart';
import 'package:nerimobile/stores/server/server_store.dart';
import 'package:nerimobile/theme/sizing/border.dart';
import 'package:flutter/material.dart';

import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/breakpoints.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';
import 'package:nerimobile/views/avatar.dart';
import 'package:nerimobile/views/shell/destinations.dart';
import 'package:nerimobile/views/shell/widgets/destination_icon.dart';
import 'package:nerimobile/views/shell/widgets/scroll_fade.dart';
import 'package:nerimobile/views/skeleton/skeleton.dart';

const _skeletonServers = 6;
const _unreadBlobRatio = 0.35;
const _selectedBlobRatio = 0.55;
const _morph = Duration(milliseconds: 200);

class NavRail extends StatelessWidget {
  const NavRail({super.key, required this.branch, required this.onSelect});

  final NeriBranch branch;
  final ValueChanged<NeriDestination> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;

    return Container(
      width: sizing.dimen(NeriDimen.railWidth),
      color: colors[NeriToken.rail],
      child: Column(
        children: [
          Expanded(
            child: ScrollFade(
              color: colors[NeriToken.rail],
              child: _ServerList(
                selectedId: branch == NeriBranch.servers
                    ? GoRouterState.of(context).pathParameters['serverId']
                    : null,
              ),
            ),
          ),
          if (NeriWindow.of(context).destinationsInRail)
            SafeArea(
              top: false,
              right: false,
              child: Column(
                children: [
                  for (final destination in neriDestinations)
                    _RailItem(
                      destination: destination,
                      selected:
                          destination is BranchDestination &&
                          destination.branch == branch,
                      size: sizing.dimen(NeriDimen.controlSize),
                      onTap: () => onSelect(destination),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ServerList extends ConsumerWidget {
  const _ServerList({required this.selectedId});

  final String? selectedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sizing = context.neriSize;
    final servers = ref.watch(sortedServersProvider);
    final unknown =
        servers.isEmpty && ref.watch(cacheHydrationProvider).isLoading;
    final padding = EdgeInsets.only(
      top: sizing.space(NeriSpacingRole.sm),
      bottom: sizing.dimen(NeriDimen.fadeHeight),
    );

    if (unknown) {
      return SkeletonScope(
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: padding,
          itemCount: _skeletonServers,
          itemBuilder: (context, _) => const _ServerSkeleton(),
        ),
      );
    }

    return ListView.builder(
      padding: padding,
      itemCount: servers.length,
      itemBuilder: (context, index) {
        final server = servers[index];
        return _ServerItem(server: server, selected: server.id == selectedId);
      },
    );
  }
}

class _ServerItem extends ConsumerWidget {
  const _ServerItem({required this.server, required this.selected});

  final Server server;
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final size = sizing.dimen(NeriDimen.avatarMd);
    final notification = ref.watch(
      serverNotificationsProvider.select((n) => n[server.id]),
    );

    final mentions = notification != null && notification > 0
        ? notification
        : null;
    final badge = mentions == null
        ? null
        : _mentionRect(context, '$mentions', size);

    return Stack(
      alignment: Alignment.center,
      children: [
        Semantics(
          button: true,
          selected: selected,
          label: server.name,
          child: GestureDetector(
            onTap: () => context.go('/app/servers/${server.id}'),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: EdgeInsets.all(sizing.space(NeriSpacingRole.xs)),
              decoration: BoxDecoration(
                color: selected
                    ? colors[NeriToken.navIndicator]
                    : Colors.transparent,
                borderRadius: sizing.rounded(NeriRadiusRole.xl),
              ),
              child: SizedBox.square(
                dimension: size,
                child: Stack(
                  children: [
                    ClipPath(
                      clipper: badge == null
                          ? null
                          : _Punch(
                              RRect.fromRectAndRadius(
                                badge.inflate(
                                  sizing.border(NeriBorderRole.medium),
                                ),
                                Radius.circular(badge.height),
                              ),
                            ),
                      child: TweenAnimationBuilder(
                        tween: Tween<double>(
                          end: selected
                              ? sizing.radius(NeriRadiusRole.lg)
                              : size / 2,
                        ),
                        duration: _morph,
                        curve: Curves.easeOut,
                        builder: (context, radius, _) => Avatar(
                          server: server,
                          size: size,
                          animate: selected,
                          borderRadius: BorderRadius.circular(radius),
                        ),
                      ),
                    ),
                    if (badge != null)
                      Positioned.fromRect(
                        rect: badge,
                        child: _MentionCount(count: mentions!),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          //-1 is unread without a mention
          child: _UnreadBlob(
            visible: notification == -1,
            height: size * (selected ? _selectedBlobRatio : _unreadBlobRatio),
          ),
        ),
      ],
    );
  }
}

Rect _mentionRect(BuildContext context, String label, double size) {
  final painter = TextPainter(
    text: TextSpan(
      text: label,
      style: context.neriText[NeriTextRole.labelSmall],
    ),
    textDirection: TextDirection.ltr,
    textScaler: MediaQuery.textScalerOf(context),
  )..layout();
  final height = painter.height;
  final width = max(
    height,
    painter.width + context.neriSize.space(NeriSpacingRole.xs) * 3,
  );
  painter.dispose();

  return Rect.fromLTWH(size - width, size - height, width, height);
}

class _Punch extends CustomClipper<Path> {
  const _Punch(this.hole);

  final RRect hole;

  @override
  Path getClip(Size size) => Path.combine(
    PathOperation.difference,
    Path()..addRect(Offset.zero & size),
    Path()..addRRect(hole),
  );

  @override
  bool shouldReclip(_Punch oldClipper) => oldClipper.hole != hole;
}

class _MentionCount extends StatelessWidget {
  const _MentionCount({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors[NeriToken.alert],
        borderRadius: context.neriSize.rounded(NeriRadiusRole.full),
      ),
      child: Center(
        child: Text(
          '$count',
          style: context.neriText[NeriTextRole.labelSmall].copyWith(
            color: colors[NeriToken.background],
          ),
        ),
      ),
    );
  }
}

class _UnreadBlob extends StatelessWidget {
  const _UnreadBlob({required this.visible, required this.height});

  final bool visible;
  final double height;

  @override
  Widget build(BuildContext context) {
    final sizing = context.neriSize;
    final radius = Radius.circular(sizing.radius(NeriRadiusRole.full));

    return AnimatedContainer(
      duration: _morph,
      curve: Curves.easeOut,
      width: sizing.space(NeriSpacingRole.xs),
      height: visible ? height : 0,
      decoration: BoxDecoration(
        color: context.neri[NeriToken.unreadDot],
        borderRadius: BorderRadius.only(topRight: radius, bottomRight: radius),
      ),
    );
  }
}

class _ServerSkeleton extends StatelessWidget {
  const _ServerSkeleton();

  @override
  Widget build(BuildContext context) {
    final sizing = context.neriSize;
    final size = sizing.dimen(NeriDimen.avatarMd);

    return Padding(
      padding: EdgeInsets.only(bottom: sizing.space(NeriSpacingRole.xs)),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(sizing.space(NeriSpacingRole.xs)),
          child: SkeletonBlock(
            width: size,
            height: size,
            shape: NeriRadiusRole.full,
          ),
        ),
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.destination,
    required this.selected,
    required this.size,
    required this.onTap,
  });

  final NeriDestination destination;
  final bool selected;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;

    return Padding(
      padding: EdgeInsets.only(top: sizing.space(NeriSpacingRole.xs)),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: selected
                ? colors[NeriToken.navIndicator]
                : Colors.transparent,
            borderRadius: sizing.rounded(NeriRadiusRole.xl),
          ),
          child: DestinationIcon(
            destination: destination,
            selected: selected,
            size: size,
            surface: colors[NeriToken.rail],
          ),
        ),
      ),
    );
  }
}
