import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:nerimobile/utils/cached_svg_loader.dart';
import 'package:nerimobile/utils/emojis.dart';
import 'package:nerimobile/views/chat/message/emoji/emoji_size.dart';

class Twemoji extends StatelessWidget {
  const Twemoji({
    super.key,
    required this.unicode,
    this.size,
    this.placeholder,
  });

  final String unicode;
  final double? size;
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    final size = this.size ?? EmojiSizeScope.of(context);

    return SvgPicture(
      CachedSvgLoader(unicodeToTwemojiUrl(unicode)),
      width: size,
      height: size,
      placeholderBuilder: (_) =>
          placeholder ?? SizedBox.square(dimension: size),
      errorBuilder: (_, _, _) => Text(unicode),
    );
  }
}
