import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nerimobile/utils/caches.dart';

import 'package:nerimobile/utils/image.dart';

class BannerImage extends StatelessWidget {
  const BannerImage({super.key, required this.path, required this.fallback});

  final String? path;
  final Color fallback;

  @override
  Widget build(BuildContext context) {
    final placeholder = ColoredBox(color: fallback);
    final path = this.path;
    if (path == null || path.isEmpty) return placeholder;

    return LayoutBuilder(
      builder: (context, constraints) => CachedNetworkImage(
        imageUrl: buildImageUrl(
          path,
          size: (constraints.maxWidth * MediaQuery.devicePixelRatioOf(context))
              .round(),
        ),
        cacheManager: mediaCache,
        fit: BoxFit.cover,
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        placeholder: (_, _) => placeholder,
        errorWidget: (_, _, _) => placeholder,
      ),
    );
  }
}
