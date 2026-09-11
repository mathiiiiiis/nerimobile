import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:nerimobile/config.dart';

const emojiSize = 20.0;

//ace==legacy animated, wace==same emoji as animated webp
enum CustomEmojiKind {
  static('ce'),
  animatedGif('ace'),
  animatedWebp('wace');

  final String type;
  const CustomEmojiKind(this.type);

  bool get animated => this != CustomEmojiKind.static;

  static final _byType = {for (final k in CustomEmojiKind.values) k.type: k};
  static CustomEmojiKind? fromType(String type) => _byType[type];
}

String customEmojiUrl(
  String id,
  CustomEmojiKind kind, {
  required bool animate,
  double? size,
}) {
  final extension = kind == CustomEmojiKind.animatedGif ? 'gif' : 'webp';
  final query = <String, String>{
    if (kind.animated && !animate) 'type': 'webp',
    if (size != null) 'size': size.round().toString(),
  };

  return Uri.parse(
    '${cdnUrl}emojis/$id.$extension',
  ).replace(queryParameters: query.isEmpty ? null : query).toString();
}

class CustomEmoji extends StatelessWidget {
  const CustomEmoji({
    super.key,
    required this.id,
    required this.name,
    required this.kind,
    this.size = emojiSize,
  });

  final String id;
  final String name;
  final CustomEmojiKind kind;
  final double size;

  @override
  Widget build(BuildContext context) {
    final pixels = size * MediaQuery.devicePixelRatioOf(context);

    return CachedNetworkImage(
      imageUrl: customEmojiUrl(id, kind, animate: true, size: pixels),
      width: size,
      height: size,
      fit: BoxFit.contain,
      placeholder: (_, _) => SizedBox(width: size, height: size),
      errorWidget: (_, _, _) => Text(':$name'),
    );
  }
}
