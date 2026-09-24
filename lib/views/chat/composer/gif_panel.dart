import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:nerimobile/models/gif.dart';
import 'package:nerimobile/stores/gif/gif_store.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';
import 'package:nerimobile/utils/caches.dart';
import 'package:nerimobile/utils/image.dart';
import 'package:nerimobile/views/empty_state.dart';
import 'package:nerimobile/views/skeleton/skeleton.dart';

const _columns = 2;
const _tileRatio = 16 / 9;
const _skeletonTiles = 6;
const _scrimOpacity = 0.65;
const _scrimStop = 0.55;
const _creditHeight = 14.0;

class GifPanel extends ConsumerWidget {
  const GifPanel({super.key, required this.channelId});

  final String channelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(gifCategoriesProvider);

    return switch (categories) {
      AsyncData(:final value) when value.isNotEmpty => _Categories(
        categories: value,
      ),
      AsyncData() => _pinned(
        context,
        const EmptyState(
          message: 'No GIF categories now', //TODO: add l10n
          icon: Symbols.gif_box_rounded,
        ),
      ),
      AsyncError() => _pinned(
        context,
        _Failed(onRetry: () => ref.invalidate(gifCategoriesProvider)),
      ),
      _ => _pinned(context, const _Loading()),
    };
  }
}

Widget _pinned(BuildContext context, Widget child) => Column(
  spacing: context.neriSize.space(NeriSpacingRole.sm),
  children: [
    Expanded(child: child),
    const _Credit(),
  ],
);

SliverGridDelegate _grid(BuildContext context) {
  final gap = context.neriSize.space(NeriSpacingRole.sm);

  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: _columns,
    mainAxisSpacing: gap,
    crossAxisSpacing: gap,
    childAspectRatio: _tileRatio,
  );
}

class _Categories extends StatelessWidget {
  const _Categories({required this.categories});

  final List<GifCategory> categories;

  @override
  Widget build(BuildContext context) {
    final gap = context.neriSize.space(NeriSpacingRole.sm);

    return CustomScrollView(
      slivers: [
        SliverGrid.builder(
          gridDelegate: _grid(context),
          itemCount: categories.length,
          itemBuilder: (context, index) =>
              _CategoryTile(category: categories[index]),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: gap),
            child: const Center(child: _Credit()),
          ),
        ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category});

  final GifCategory category;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;

    return LayoutBuilder(
      builder: (context, constraints) => ClipRRect(
        borderRadius: sizing.rounded(NeriRadiusRole.image),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: proxiedGifUrl(category.image),
              cacheManager: mediaCache,
              fit: BoxFit.cover,
              memCacheWidth:
                  (constraints.maxWidth *
                          MediaQuery.devicePixelRatioOf(context))
                      .round(),
              fadeInDuration: Duration.zero,
              fadeOutDuration: Duration.zero,
              placeholder: (_, _) => const SkeletonScope(
                child: SkeletonBlock(height: double.infinity),
              ),
              errorWidget: (_, _, _) =>
                  ColoredBox(color: colors[NeriToken.card]),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: const [0, _scrimStop],
                  colors: [
                    Colors.black.withValues(alpha: _scrimOpacity),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.all(sizing.space(NeriSpacingRole.sm)),
                child: Text(
                  category.searchTerm,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.neriText[NeriTextRole.labelLarge].copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) => SkeletonScope(
    child: GridView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: _grid(context),
      itemCount: _skeletonTiles,
      itemBuilder: (context, index) => const SkeletonBlock(
        height: double.infinity,
        shape: NeriRadiusRole.image,
      ),
    ),
  );
}

class _Failed extends StatelessWidget {
  const _Failed({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onRetry,
    child: const EmptyState(
      message: 'Could not load GIF categories :/', //TODO: add l10n
      hint: 'Tap try again', //TODO: add l10n
      icon: Symbols.gif_box_rounded,
    ),
  );
}

class _Credit extends StatelessWidget {
  const _Credit();

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    Theme.of(context).brightness == Brightness.dark
        ? 'assets/klipy/powered-by-klipy-white.svg'
        : 'assets/klipy/powered-by-klipy-black.svg',
    height: _creditHeight,
    semanticsLabel: 'Powered by KLIPY',
  );
}
