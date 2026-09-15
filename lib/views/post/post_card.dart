import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:nerimobile/models/post.dart';
import 'package:nerimobile/models/user.dart';

import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/border.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';
import 'package:nerimobile/utils/date.dart';
import 'package:nerimobile/views/avatar.dart';
import 'package:nerimobile/views/chat/message/message_media.dart';
import 'package:nerimobile/views/markup/markup.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post, this.action});

  final Post post;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final body = post.repost ?? post;

    return Container(
      padding: EdgeInsets.all(sizing.space(NeriSpacingRole.md)),
      decoration: BoxDecoration(
        color: colors[NeriToken.card],
        borderRadius: sizing.rounded(NeriRadiusRole.lg),
        border: Border.all(
          color: colors[NeriToken.border],
          width: sizing.border(NeriBorderRole.hairline),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: sizing.space(NeriSpacingRole.sm),
        children: [
          if (post.reposts.isNotEmpty)
            _RepostedBy(users: post.reposts)
          else if (post.isRepost)
            _RepostedBy(users: [post.createdBy]),
          _Author(post: body, action: action),
          if (body.content case final content?)
            MarkupView(rawText: content, mentions: body.mentions),
          MediaPreview(attachments: body.attachments, embed: body.embed),
          _Counts(post: body),
        ],
      ),
    );
  }
}

class _RepostedBy extends StatelessWidget {
  const _RepostedBy({required this.users});

  final List<User> users;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;

    return Row(
      spacing: sizing.space(NeriSpacingRole.xs),
      children: [
        Icon(
          Symbols.repeat_rounded,
          size: sizing.dimen(NeriDimen.iconSm) * 0.6,
          color: colors[NeriToken.success],
        ),
        Text(
          'Reposted by ${users.map((u) => u.username).join(', ')}', //TODO: add l10n
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.neriText[NeriTextRole.bodySmall].copyWith(
            color: colors[NeriToken.textPlaceholder],
          ),
        ),
      ],
    );
  }
}

class _Author extends StatelessWidget {
  const _Author({required this.post, this.action});

  final Post post;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final text = context.neriText;

    return Row(
      spacing: sizing.space(NeriSpacingRole.sm),
      children: [
        Avatar(
          size: (sizing.dimen(NeriDimen.avatarMd) * 0.5),
          user: post.createdBy,
        ),
        Flexible(
          child: Text(
            post.createdBy.username,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text[NeriTextRole.labelLarge].copyWith(
              color: colors[NeriToken.text],
            ),
          ),
        ),
        Text(
          formatTimestamp(post.createdAt),
          style: text[NeriTextRole.bodySmall].copyWith(
            color: colors[NeriToken.textPlaceholder],
          ),
        ),
        Spacer(),
        ?action,
      ],
    );
  }
}

class _Counts extends StatelessWidget {
  const _Counts({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final sizing = context.neriSize;

    return Row(
      spacing: sizing.space(NeriSpacingRole.md),
      children: [
        _Count(
          icon: Symbols.favorite_rounded,
          value: post.likeCount,
          highlighted: post.likedByMe,
        ),
        _Count(icon: Symbols.chat_bubble_rounded, value: post.commentCount),
        _Count(icon: Symbols.repeat_rounded, value: post.repostCount),
        Spacer(),
        _Count(icon: Symbols.visibility_rounded, value: post.views),
      ],
    );
  }
}

class _Count extends StatelessWidget {
  const _Count({
    required this.icon,
    required this.value,
    this.highlighted = false,
  });

  final IconData icon;
  final int value;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final color = highlighted
        ? colors[NeriToken.alert]
        : colors[NeriToken.textPlaceholder];

    return Row(
      spacing: sizing.space(NeriSpacingRole.xs),
      children: [
        Icon(
          icon,
          size: sizing.dimen(NeriDimen.iconSm) * 0.7,
          color: color,
          fill: highlighted ? 1 : 0,
        ),
        Text(
          '$value',
          style: context.neriText[NeriTextRole.bodySmall].copyWith(
            color: color,
          ),
        ),
      ],
    );
  }
}
