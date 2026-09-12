import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:nerimobile/models/channel.dart';
import 'package:nerimobile/models/server_role.dart';
import 'package:nerimobile/utils/cached_svg_loader.dart';
import 'package:nerimobile/utils/emojis.dart';
import 'package:nerimobile/utils/image.dart';

class CdnIcon extends StatelessWidget {
  final Channel? channel;
  final ServerRole? serverRole;
  final String? path;
  final double size;
  final IconData? fallbackIcon;
  const CdnIcon({
    super.key,
    this.channel,
    this.fallbackIcon,
    this.serverRole,
    this.path,
    required this.size,
  });

  Widget _fallback() => fallbackIcon == null
      ? const SizedBox.shrink()
      : Icon(fallbackIcon, size: size);

  @override
  Widget build(BuildContext context) {
    final icon = channel?.icon ?? serverRole?.icon ?? path;
    if (icon == null) return _fallback();

    final isSvgIcon = !icon.contains(".");

    if (isSvgIcon) {
      return SvgPicture(
        CachedSvgLoader(unicodeToTwemojiUrl(icon)),
        width: size,
        height: size,
        placeholderBuilder: (_) => SizedBox.square(dimension: size),
        errorBuilder: (_, _, _) => _fallback(),
      );
    }

    final pixels = size * MediaQuery.devicePixelRatioOf(context);

    return CachedNetworkImage(
      imageUrl: buildImageUrl('emojis/$icon', size: pixels.toInt()),
      fit: BoxFit.scaleDown,
      width: size,
      height: size,
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      placeholder: (_, _) => SizedBox.square(dimension: size),
      errorWidget: (_, _, _) => _fallback(),
    );
  }
}
