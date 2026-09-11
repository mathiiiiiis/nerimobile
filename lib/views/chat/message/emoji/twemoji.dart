import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:nerimobile/utils/cached_svg_loader.dart';
import 'package:nerimobile/utils/emojis.dart';
import 'package:nerimobile/views/chat/message/emoji/custom_emoji.dart';

class Twemoji extends StatelessWidget {
  const Twemoji({super.key, required this.unicode, this.size = emojiSize});

  final String unicode;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture(
      CachedSvgLoader(unicodeToTwemojiUrl(unicode)),
      width: size,
      height: size,
      placeholderBuilder: (_) => SizedBox.square(dimension: size),
      errorBuilder: (_, _, _) => Text(unicode),
    );
  }
}
