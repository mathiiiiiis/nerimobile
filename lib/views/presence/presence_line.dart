import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import 'package:nerimobile/models/user_presence.dart';
import 'package:nerimobile/stores/user/user_presence_store.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';

ActivityKind activityKindOf(ActivityStatus activity) {
  if (activity.action.startsWith('Listening to')) return ActivityKind.music;
  if (activity.action.startsWith('Watching')) return ActivityKind.video;
  return ActivityKind.game;
}

enum ActivityKind {
  music(Symbols.music_note_rounded),
  video(Symbols.movie_rounded),
  game(Symbols.gamepad_rounded);

  const ActivityKind(this.icon);

  final IconData icon;
}

class PresenceLine extends ConsumerWidget {
  const PresenceLine({
    super.key,
    required this.userId,
    this.role = NeriTextRole.bodySmall,
  });

  final String userId;
  final NeriTextRole role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.neri;
    final presence = ref.watch(presencesProvider)[userId];
    final style = context.neriText[role];

    final activity = presence?.activity;
    if (activity != null) {
      return _ActivityLine(
        activity: activity,
        extra: (presence!.activities?.length ?? 1) - 1,
        style: style,
        color: colors[_statusOf(presence).token],
      );
    }

    final custom = presence?.custom;
    final status = _statusOf(presence);

    return Text(
      custom != null && custom.isNotEmpty ? custom : status.name,
      overflow: TextOverflow.ellipsis,
      style: style.copyWith(color: colors[NeriToken.textPlaceholder]),
    );
  }
}

PresenceStatus _statusOf(UserPresence? presence) =>
    PresenceStatus.fromValue(presence?.status ?? 0) ?? PresenceStatus.offline;

class _ActivityLine extends StatelessWidget {
  const _ActivityLine({
    required this.activity,
    required this.extra,
    required this.style,
    required this.color,
  });

  final ActivityStatus activity;
  final int extra;
  final TextStyle style;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final kind = activityKindOf(activity);

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: sizing.space(NeriSpacingRole.xs),
      children: [
        Icon(
          kind.icon,
          fill: 1,
          size: sizing.dimen(NeriDimen.iconSm) * 0.7,
          color: color,
        ),
        Flexible(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: activity.action,
                  style: TextStyle(color: colors[NeriToken.text]),
                ),
                if (extra > 0)
                  TextSpan(
                    text: ' +$extra',
                    style: TextStyle(color: colors[NeriToken.textPlaceholder]),
                  ),
                TextSpan(
                  text: ' ${activity.name}',
                  style: TextStyle(color: colors[NeriToken.textPlaceholder]),
                ),
              ],
            ),
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
      ],
    );
  }
}
