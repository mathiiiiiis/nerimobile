import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:nerimobile/models/user_presence.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/utils/caches.dart';
import 'package:nerimobile/utils/emoji/emojis.dart';
import 'package:nerimobile/utils/image.dart';
import 'package:nerimobile/views/emoji/twemoji.dart';
import 'package:nerimobile/views/user/presence_line.dart';

const _blur = 10.0;
const _backdropScale = 2.0;
const _backdropOpacity = 0.7;
const _videoAspect = 16 / 9;

class ActivityArt extends StatelessWidget {
  const ActivityArt({super.key, required this.activity, required this.height});

  final ActivityStatus activity;
  final double height;

  @override
  Widget build(BuildContext context) {
    final emoji = activity.emoji;
    if (emoji != null) return _EmojiArt(emoji: emoji, size: height);

    final art = activity.imgSrc;
    if (art == null) return const SizedBox.shrink();

    final video = activityKindOf(activity) == ActivityKind.video;
    final width = video ? height * _videoAspect : height;
    final empty = SizedBox(width: width, height: height);

    return ClipRRect(
      borderRadius: context.neriSize.rounded(NeriRadiusRole.image),
      child: CachedNetworkImage(
        imageUrl: proxiedImageUrl(art),
        cacheManager: mediaCache,
        width: width,
        height: height,
        fit: BoxFit.cover,
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        placeholder: (_, _) => empty,
        errorWidget: (_, _, _) => empty,
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
