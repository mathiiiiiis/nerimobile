import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nerimobile/stores/dashboard/activity_store.dart';
import 'package:nerimobile/stores/user/user_store.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/border.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';
import 'package:nerimobile/utils/format.dart';
import 'package:nerimobile/views/user/activity_art.dart';
import 'package:nerimobile/views/user/avatar.dart';
import 'package:nerimobile/views/core/list/empty_state.dart';
import 'package:nerimobile/views/markup/markup.dart';
import 'package:nerimobile/views/user/presence_line.dart';
import 'package:nerimobile/views/core/list/skeleton.dart';

const _cardWidth = 240.0;
const _cardHeight = 90.0;
const _avatarSize = 20.0;
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
          ActivityArt(
            activity: activity.activity,
            height: _cardHeight - inset * 2,
          ),
          Expanded(child: _Details(activity: activity)),
        ],
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
              DefaultTextStyle(
                style: text[NeriTextRole.bodyMedium].copyWith(
                  color: colors[NeriToken.textPlaceholder],
                ),
                child: MarkupView(
                  rawText: singleLine(title),
                  inline: true,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
