import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nerimobile/models/inbox.dart';
import 'package:nerimobile/models/user_presence.dart';
import 'package:nerimobile/stores/inbox/inbox_store.dart';
import 'package:nerimobile/stores/message/message_mention_store.dart';
import 'package:nerimobile/stores/user/user_presence_store.dart';

import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/breakpoints.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';
import 'package:nerimobile/views/avatar.dart';
import 'package:nerimobile/views/shell/widgets/scroll_fade.dart';

const _presenceDotRatio = 0.25;

class DmListPane extends ConsumerWidget {
  const DmListPane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final inbox = ref.watch(sortedInboxProvider);
    final framed = NeriWindow.of(context).isDualPane;
    final surface = framed
        ? colors[NeriToken.background]
        : colors[NeriToken.pane];

    final list = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (framed)
          Padding(
            padding: EdgeInsets.all(sizing.space(NeriSpacingRole.md)),
            child: Text(
              'Direct Messages', //TODO: add l10n
              style: context.neriText[NeriTextRole.headlineSmall].copyWith(
                color: colors[NeriToken.text],
              ),
            ),
          ),
        Expanded(
          child: ScrollFade(
            color: surface,
            child: ListView.builder(
              padding: EdgeInsets.only(
                bottom: sizing.dimen(NeriDimen.fadeHeight),
              ),
              itemCount: inbox.length,
              itemBuilder: (context, index) => DmRow(inbox: inbox[index]),
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
            width: sizing.dimen(NeriDimen.borderWidth),
          ),
        ),
        child: list,
      ),
    );
  }
}

class DmRow extends ConsumerWidget {
  const DmRow({super.key, required this.inbox});

  final Inbox inbox;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final size = sizing.dimen(NeriDimen.avatarMd);

    final presence = ref.watch(presencesProvider)[inbox.recipientId];
    final status =
        PresenceStatus.fromValue(presence?.status ?? 0) ??
        PresenceStatus.offline;
    final mentions = ref.watch(messageMentionsProvider)[inbox.channelId];

    return InkWell(
      onTap: () => context.go('/app/inbox/${inbox.channelId}'),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: sizing.space(NeriSpacingRole.sm),
          vertical: sizing.space(NeriSpacingRole.xs),
        ),
        child: Row(
          spacing: sizing.space(NeriSpacingRole.md),
          children: [
            _AvatarWithPresence(
              inbox: inbox,
              size: size,
              status: status,
              surface: NeriWindow.of(context).isDualPane
                  ? colors[NeriToken.background]
                  : colors[NeriToken.pane],
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    inbox.recipient.username,
                    overflow: TextOverflow.ellipsis,
                    style: context.neriText[NeriTextRole.bodyLarge].copyWith(
                      color: colors[NeriToken.textSecondary],
                    ),
                  ),
                  Text(
                    status.name,
                    overflow: TextOverflow.ellipsis,
                    style: context.neriText[NeriTextRole.bodySmall].copyWith(
                      color: colors[NeriToken.textPlaceholder],
                    ),
                  ),
                ],
              ),
            ),
            if (mentions != null && mentions.count > 0)
              _MentionBadge(count: mentions.count),
          ],
        ),
      ),
    );
  }
}

class _AvatarWithPresence extends StatelessWidget {
  const _AvatarWithPresence({
    required this.inbox,
    required this.size,
    required this.status,
    required this.surface,
  });

  final Inbox inbox;
  final double size;
  final PresenceStatus status;
  final Color surface;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final dot = size * _presenceDotRatio;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Avatar(user: inbox.recipient, size: size),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: dot,
              height: dot,
              decoration: BoxDecoration(
                color: colors[status.token],
                shape: BoxShape.circle,
                border: Border.all(
                  color: surface,
                  width: context.neriSize.dimen(NeriDimen.avatarRingWidth),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MentionBadge extends StatelessWidget {
  const _MentionBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sizing.space(NeriSpacingRole.sm),
        vertical: sizing.space(NeriSpacingRole.xs) / 2,
      ),
      decoration: BoxDecoration(
        color: colors[NeriToken.mentionBadge],
        borderRadius: sizing.rounded(NeriRadiusRole.full),
      ),
      child: Text(
        '$count',
        style: context.neriText[NeriTextRole.labelSmall].copyWith(
          color: colors[NeriToken.background],
        ),
      ),
    );
  }
}
