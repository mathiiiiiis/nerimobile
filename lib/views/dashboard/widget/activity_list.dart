import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nerimobile/models/user_presence.dart';
import 'package:nerimobile/stores/dashboard/activity_store.dart';
import 'package:nerimobile/stores/user/user_store.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/border.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';
import 'package:nerimobile/utils/caches.dart';
import 'package:nerimobile/utils/emojis.dart';
import 'package:nerimobile/utils/image.dart';
import 'package:nerimobile/views/avatar.dart';
import 'package:nerimobile/views/chat/message/emoji/twemoji.dart';
import 'package:nerimobile/views/empty_state.dart';
import 'package:nerimobile/views/presence/presence_line.dart';
import 'package:nerimobile/views/skeleton/skeleton.dart';

const _cardWidth = 240.0;
const _cardHeight = 90.0;
const _avatarSize = 20.0;
const _blur = 10.0;
const _backdropScale = 2.0;
const _backdropOpacity = 0.7;
const _skeletonCards = 5;

class ActivityList extends ConsumerWidget {
  const ActivityList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(activitiesProvider);
    final sizing = context.neriSize;

    if (activities.isEmpty) {
      if (ref.watch(currentUserProvider) == null) {
        return const SizedBox(height: _cardHeight, child: _ActivitySkeleton());
      }

      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: sizing.space(NeriSpacingRole.md),
        ),
        child: const SizedBox(
          height: _cardHeight,
          child: EmptyState(
            message: 'No one is active right now',
          ), //TODO: add l10n
        ),
      );
    }

    return SizedBox(
      height: _cardHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: sizing.space(NeriSpacingRole.md),
        ),
        itemCount: activities.length,
        itemBuilder: (context, index) =>
            _ActivityCard(activity: activities[index]),
        separatorBuilder: (_, _) =>
            SizedBox(width: sizing.space(NeriSpacingRole.sm)),
      ),
    );
  }
}

class _ActivitySkeleton extends StatelessWidget {
  const _ActivitySkeleton();

  @override
  Widget build(BuildContext context) {
    final sizing = context.neriSize;

    return SkeletonScope(
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: sizing.space(NeriSpacingRole.md),
        ),
        itemCount: _skeletonCards,
        itemBuilder: (_, _) => const SkeletonBlock(
          width: _cardWidth,
          height: _cardHeight,
          shape: NeriRadiusRole.lg,
        ),
        separatorBuilder: (_, _) =>
            SizedBox(width: sizing.space(NeriSpacingRole.sm)),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activity});

  final UserActivity activity;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final inset = sizing.space(NeriSpacingRole.xs);

    return Container(
      width: _cardWidth,
      padding: EdgeInsets.all(inset),
      decoration: BoxDecoration(
        color: colors[NeriToken.card],
        borderRadius: sizing.rounded(NeriRadiusRole.lg),
        border: Border.all(
          color: colors[NeriToken.border],
          width: sizing.border(NeriBorderRole.hairline),
        ),
      ),
      child: Row(
        spacing: sizing.space(NeriSpacingRole.md),
        children: [
          _Art(activity: activity.activity, size: _cardHeight - inset * 2),
          Expanded(child: _Details(activity: activity)),
        ],
      ),
    );
  }
}

class _Art extends StatelessWidget {
  const _Art({required this.activity, required this.size});

  final ActivityStatus activity;
  final double size;

  @override
  Widget build(BuildContext context) {
    final emoji = activity.emoji;
    if (emoji != null) return _EmojiArt(emoji: emoji, size: size);

    final art = activity.imgSrc;
    if (art == null) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: context.neriSize.rounded(NeriRadiusRole.image),
      child: CachedNetworkImage(
        imageUrl: proxiedImageUrl(art),
        cacheManager: mediaCache,
        width: size,
        height: size,
        fit: BoxFit.cover,
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        placeholder: (_, _) => SizedBox.square(dimension: size),
        errorWidget: (_, _, _) => SizedBox.square(dimension: size),
      ),
    );
  }
}

class _EmojiArt extends StatelessWidget {
  const _EmojiArt({required this.emoji, required this.size});

  final String emoji;
  final double size;

  Widget _emoji(double size) => isCustomEmoji(emoji)
      ? CachedNetworkImage(
          imageUrl: customEmojiUrlOf(emoji),
          cacheManager: emojiCache,
          width: size / 2,
          height: size / 2,
          fit: BoxFit.contain,
          fadeInDuration: Duration.zero,
          fadeOutDuration: Duration.zero,
          placeholder: (_, _) => SizedBox.square(dimension: size / 2),
          errorWidget: (_, _, _) => SizedBox.square(dimension: size / 2),
        )
      : Twemoji(unicode: emoji, size: size / 2);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: context.neriSize.rounded(NeriRadiusRole.image),
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: _backdropScale,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: _blur, sigmaY: _blur),
                child: Opacity(opacity: _backdropOpacity, child: _emoji(size)),
              ),
            ),
            _emoji(size),
          ],
        ),
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.activity});

  final UserActivity activity;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final text = context.neriText;
    final status = activity.activity;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: sizing.space(NeriSpacingRole.sm),
      children: [
        Row(
          spacing: sizing.space(NeriSpacingRole.xs),
          children: [
            Avatar(size: _avatarSize, user: activity.user),
            Flexible(
              child: Text(
                activity.user.username,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text[NeriTextRole.labelLarge].copyWith(
                  color: colors[NeriToken.text],
                ),
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: sizing.space(NeriSpacingRole.xs),
              children: [
                Icon(
                  activityKindOf(status).icon,
                  size: sizing.dimen(NeriDimen.iconSm) * 0.6,
                  color: colors[NeriToken.primary],
                ),
                Flexible(
                  child: Text(
                    status.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text[NeriTextRole.bodySmall].copyWith(
                      color: colors[NeriToken.primary],
                    ),
                  ),
                ),
              ],
            ),
            if (status.title case final title?)
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text[NeriTextRole.bodyMedium].copyWith(
                  color: colors[NeriToken.textPlaceholder],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
