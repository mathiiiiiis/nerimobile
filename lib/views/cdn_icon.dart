import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nerimobile/models/channel.dart';
import 'package:nerimobile/models/server_role.dart';
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

  @override
  Widget build(BuildContext context) {
    final icon = channel?.icon ?? serverRole?.icon ?? path;
    if (icon == null) {
      if (fallbackIcon != null) {
        return Icon(fallbackIcon, size: size);
      } else {
        return const SizedBox.shrink();
      }
    }

    final isSvgIcon = !icon.contains(".");

    final iconUrl = isSvgIcon
        ? unicodeToTwemojiUrl(icon)
        : buildImageUrl('emojis/$icon', size: size.toInt());

    return isSvgIcon
        ? SvgPicture.network(iconUrl, width: size, height: size)
        : Image.network(
            iconUrl,
            fit: BoxFit.scaleDown,
            width: size,
            height: size,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.shrink(),
          );
  }
}
