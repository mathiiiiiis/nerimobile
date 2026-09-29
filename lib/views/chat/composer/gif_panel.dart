import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:nerimobile/models/gif.dart';
import 'package:nerimobile/stores/composer/composer_store.dart';
import 'package:nerimobile/stores/gif/favorite_gif_store.dart';
import 'package:nerimobile/stores/gif/gif_store.dart';
import 'package:nerimobile/stores/window/window_focus_store.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';
import 'package:nerimobile/utils/caches.dart';
import 'package:nerimobile/utils/image.dart';
import 'package:nerimobile/utils/url.dart';
import 'package:nerimobile/views/app_text_field.dart';
import 'package:nerimobile/views/empty_state.dart';
import 'package:nerimobile/views/modal/bottom_sheet.dart';
import 'package:nerimobile/views/press_scale.dart';
import 'package:nerimobile/views/skeleton/skeleton.dart';

const _columns = 2;
const _tileRatio = 16 / 9;
const _skeletonTiles = 9;
const _scrimOpacity = 0.65;
const _scrimStop = 0.55;
const _searchHeight = 34.0;
const _resultRow = 180.0;
const _debounce = Duration(milliseconds: 350);
const _flexScale = 1000;
const _loadMoreExtent = 400.0;
const _skeletonRow = 3;
const _starSize = 0.35;
const _goneCodes = [404, 410];

typedef _Tile = ({
  String url,
  String? link,
  String previewUrl,
  double ratio,
  FavoriteGif favorite,
});

typedef _Row = ({List<_Tile> tiles, double height, bool justified});

_Tile _resultTile(Gif gif) => (
  url: gif.gifUrl,
  link: gif.url,
  previewUrl: gif.previewUrl,
  ratio: gif.ratio,
  favorite: FavoriteGif.of(gif, GifSource.klipy),
);

_Tile _favoriteTile(FavoriteGif gif) => (
  url: gif.url,
  link: null,
  previewUrl: gif.previewUrl,
  ratio: gif.ratio,
  favorite: gif,
);

class GifPanel extends ConsumerStatefulWidget {
  const GifPanel({
    super.key,
    required this.channelId,
    required this.onSearching,
    required this.onPicked,
  });

  final String channelId;
  final ValueChanged<bool> onSearching;
  final VoidCallback onPicked;

  @override
  ConsumerState<GifPanel> createState() => _GifPanelState();
}

class _GifPanelState extends ConsumerState<GifPanel> {
  final _search = TextEditingController();
  final _searchFocus = FocusNode();
  Timer? _timer;
  var _query = '';
  var _favorites = false;
  var _seed = 0;

  @override
  void initState() {
    super.initState();
    _seed = Random().nextInt(1 << 32);
    _searchFocus.addListener(() => widget.onSearching(_searchFocus.hasFocus));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  //search route it rate limited
  void _onQuery(String value) {
    _timer?.cancel();
    _timer = Timer(_debounce, () => _setQuery(value));
  }

  void _setQuery(String value) {
    final query = value.trim();
    if (query == _query) return;

    setState(() => _query = query);
  }

  void _searchFor(String term) {
    _timer?.cancel();
    _search.text = term;
    _setQuery(term);
  }

  void _openFavorites() {
    _searchFocus.unfocus();
    setState(() => _favorites = true);
  }

  void _closeFavorites() => setState(() => _favorites = false);

  void _insert(String url) {
    _searchFocus.unfocus();
    ref.read(composerProvider(widget.channelId).notifier).insert('$url ');
    widget.onPicked();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: switch ((_favorites, _query.isEmpty)) {
            (true, _) => _FavoritesBody(
              onPick: _insert,
              onBack: _closeFavorites,
            ),
            (_, true) => _CategoryBody(
              seed: _seed,
              onPick: _searchFor,
              onFavorites: _openFavorites,
            ),
            _ => _ResultBody(query: _query, onPick: _insert),
          },
        ),
        if (!_favorites)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppTextField(
              dense: true,
              background: NeriToken.card,
              controller: _search,
              focusNode: _searchFocus,
              onChanged: _onQuery,
              hintText: 'Search KLIPY', //TODO: add l10n
            ),
          ),
      ],
    );
  }
}

double _searchInset(BuildContext context) =>
    _searchHeight + context.neriSize.space(NeriSpacingRole.sm);

class _CategoryBody extends ConsumerWidget {
  const _CategoryBody({
    required this.seed,
    required this.onPick,
    required this.onFavorites,
  });

  final int seed;
  final ValueChanged<String> onPick;
  final VoidCallback onFavorites;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(gifCategoriesProvider);

    return switch (categories) {
      AsyncData(:final value) when value.isNotEmpty => _Categories(
        categories: value,
        seed: seed,
        onPick: onPick,
        onFavorites: onFavorites,
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
        _Failed(
          message: 'Coult not load GIFs :/', //TODO: add l10
          onRetry: () => ref.invalidate(gifCategoriesProvider),
        ),
      ),
      _ => _pinned(context, const _Loading(ratio: _tileRatio)),
    };
  }
}

class _ResultBody extends ConsumerWidget {
  const _ResultBody({required this.query, required this.onPick});

  final String query;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(gifSearchProvider(query));

    return switch (results) {
      AsyncData(:final value) when value.gifs.isNotEmpty => _GifRows(
        key: ValueKey(query),
        tiles: [for (final gif in value.gifs) _resultTile(gif)],
        padded: true,
        hasMore: value.next != null,
        onPick: (tile) => onPick(tile.url),
        onLoadMore: () =>
            ref.read(gifSearchProvider(query).notifier).loadMore(),
      ),
      AsyncData() => _pinned(
        context,
        const EmptyState(
          message: 'Not GIFs for that search :(', //TODO: add l10n
          icon: Symbols.gif_box_rounded,
        ),
      ),
      AsyncError() => _pinned(
        context,
        _Failed(
          message: 'Could not load GIFs :/',
          onRetry: () => ref.invalidate(gifSearchProvider(query)),
        ),
      ),
      _ => _pinned(context, const _Loading(ratio: 1)),
    };
  }
}

Widget _pinned(BuildContext context, Widget child) => Padding(
  padding: EdgeInsets.only(top: _searchInset(context)),
  child: child,
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
  const _Categories({
    required this.categories,
    required this.seed,
    required this.onPick,
    required this.onFavorites,
  });

  final List<GifCategory> categories;
  final int seed;
  final ValueChanged<String> onPick;
  final VoidCallback onFavorites;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.only(top: _searchInset(context)),
          sliver: SliverGrid.builder(
            gridDelegate: _grid(context),
            itemCount: categories.length + 1,
            itemBuilder: (context, index) => index == 0
                ? _FavoritesTile(seed: seed, onTap: onFavorites)
                : _CategoryTile(
                    category: categories[index - 1],
                    onTap: () => onPick(categories[index - 1].searchTerm),
                  ),
          ),
        ),
      ],
    );
  }
}

class _FavoritesTile extends ConsumerWidget {
  const _FavoritesTile({required this.seed, required this.onTap});

  final int seed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final favorites = ref.watch(favoriteGifsProvider).value ?? const [];
    final preview = favorites.isEmpty
        ? null
        : favorites[seed & favorites.length];

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: sizing.rounded(NeriRadiusRole.image),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: colors[NeriToken.card]),
            if (preview != null)
              _GifImage(url: preview.previewUrl, animate: false),
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
            LayoutBuilder(
              builder: (context, constraints) => Icon(
                Symbols.star_rounded,
                fill: 1,
                size: constraints.maxHeight * _starSize,
                color: Colors.white,
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.all(sizing.space(NeriSpacingRole.sm)),
                child: Text(
                  'Favorites', //TODO: add l10n
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

class _FavoritesHeader extends StatelessWidget {
  const _FavoritesHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;

    return SizedBox(
      height: sizing.dimen(NeriDimen.controlSize),
      child: Row(
        spacing: sizing.space(NeriSpacingRole.sm),
        children: [
          GestureDetector(
            onTap: onBack,
            child: PressScale(
              child: Icon(
                Symbols.arrow_back_rounded,
                size: sizing.dimen(NeriDimen.iconSm),
                color: colors[NeriToken.text],
              ),
            ),
          ),
          Text(
            'Favorites', //TODO: add l10n
            style: context.neriText[NeriTextRole.bodyLarge].copyWith(
              color: colors[NeriToken.text],
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoritesBody extends ConsumerWidget {
  const _FavoritesBody({required this.onPick, required this.onBack});

  final ValueChanged<String> onPick;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoriteGifsProvider).value ?? const [];

    return Column(
      spacing: context.neriSize.space(NeriSpacingRole.sm),
      children: [
        _FavoritesHeader(onBack: onBack),
        Expanded(
          child: favorites.isEmpty
              ? const EmptyState(
                  message: 'No favorite GIFs yet', //TODO: add l10n
                  icon: Symbols.sentiment_sad,
                )
              : _GifRows(
                  tiles: [for (final gif in favorites) _favoriteTile(gif)],
                  padded: false,
                  forget: true,
                  onPick: (tile) => onPick(tile.url),
                ),
        ),
      ],
    );
  }
}

class _GifImage extends StatelessWidget {
  const _GifImage({
    required this.url,
    required this.animate,
    this.width,
    this.onGone,
  });

  final String url;
  final bool animate;
  final double? width;
  final VoidCallback? onGone;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;

    return CachedNetworkImage(
      imageUrl: proxiedGifUrl(url, animate: animate),
      cacheManager: mediaCache,
      fit: BoxFit.cover,
      memCacheWidth: width == null
          ? null
          : (width! * MediaQuery.devicePixelRatioOf(context)).round(),
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      useOldImageOnUrlChange: true,
      errorListener: (error) {
        if (error is! HttpExceptionWithStatus) return;
        if (!_goneCodes.contains(error.statusCode)) return;

        onGone?.call();
      },
      placeholder: (_, _) =>
          const SkeletonScope(child: SkeletonBlock(height: double.infinity)),
      errorWidget: (_, _, _) => ColoredBox(color: colors[NeriToken.card]),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.onTap});

  final GifCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sizing = context.neriSize;

    return LayoutBuilder(
      builder: (context, constraints) => GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: sizing.rounded(NeriRadiusRole.image),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _GifImage(
                url: category.image,
                animate: false,
                width: constraints.maxWidth,
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
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading({required this.ratio});

  final double ratio;

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
  const _Failed({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onRetry,
    child: EmptyState(
      message: message, //TODO: add l10n
      hint: 'Tap try again', //TODO: add l10n
      icon: Symbols.gif_box_rounded,
    ),
  );
}

class _GifRows extends StatelessWidget {
  const _GifRows({
    super.key,
    required this.tiles,
    required this.onPick,
    required this.padded,
    this.forget = false,
    this.hasMore = false,
    this.onLoadMore,
  });

  final List<_Tile> tiles;
  final ValueChanged<_Tile> onPick;
  final bool padded;
  final bool forget;
  final bool hasMore;
  final VoidCallback? onLoadMore;

  @override
  Widget build(BuildContext context) {
    final gap = context.neriSize.space(NeriSpacingRole.sm);

    return LayoutBuilder(
      builder: (context, constraints) {
        final rows = _rows(tiles, width: constraints.maxWidth, gap: gap);
        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (hasMore && notification.metrics.extentAfter < _loadMoreExtent) {
              onLoadMore?.call();
            }
            return false;
          },
          child: ListView.separated(
            padding: EdgeInsets.only(top: padded ? _searchInset(context) : 0),
            itemCount: rows.length + (hasMore ? 1 : 0),
            separatorBuilder: (context, index) => SizedBox(height: gap),
            itemBuilder: (context, index) => index < rows.length
                ? _GifRow(
                    row: rows[index],
                    gap: gap,
                    onPick: onPick,
                    forget: forget,
                  )
                : _LoadingRow(gap: gap),
          ),
        );
      },
    );
  }
}

class _LoadingRow extends StatelessWidget {
  const _LoadingRow({required this.gap});

  final double gap;

  @override
  Widget build(BuildContext context) => SkeletonScope(
    child: Row(
      spacing: gap,
      children: [
        for (var i = 0; i < _skeletonRow; i++)
          const Expanded(
            child: SkeletonBlock(
              height: _resultRow,
              shape: NeriRadiusRole.image,
            ),
          ),
      ],
    ),
  );
}

List<_Row> _rows(
  List<_Tile> tiles, {
  required double width,
  required double gap,
}) {
  final rows = <_Row>[];
  var row = <_Tile>[];
  var ratios = 0.0;

  for (final tile in tiles) {
    row.add(tile);
    ratios += tile.ratio;

    final height = (width - gap * (row.length - 1)) / ratios;
    if (height > _resultRow) continue;

    rows.add((tiles: row, height: height, justified: true));
    row = [];
    ratios = 0;
  }

  if (row.isNotEmpty) {
    final height = (width - gap * (row.length - 1)) / ratios;
    rows.add((tiles: row, height: min(height, _resultRow), justified: false));
  }

  return rows;
}

class _GifRow extends StatelessWidget {
  const _GifRow({
    required this.row,
    required this.gap,
    required this.onPick,
    required this.forget,
  });

  final _Row row;
  final double gap;
  final ValueChanged<_Tile> onPick;
  final bool forget;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: row.height,
    child: Row(
      spacing: gap,
      children: [
        for (final tile in row.tiles)
          if (row.justified)
            Expanded(
              flex: (tile.ratio * _flexScale).round(),
              child: _GifTile(
                tile: tile,
                forget: forget,
                onTap: () => onPick(tile),
              ),
            )
          else
            SizedBox(
              width: row.height * tile.ratio,
              child: _GifTile(
                tile: tile,
                forget: forget,
                onTap: () => onPick(tile),
              ),
            ),
      ],
    ),
  );
}

class _GifTile extends ConsumerWidget {
  const _GifTile({
    required this.tile,
    required this.onTap,
    this.forget = false,
  });

  final _Tile tile;
  final VoidCallback onTap;
  final bool forget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animate = ref.watch(windowFocusProvider);

    return GestureDetector(
      onTap: onTap,
      onLongPress: () {
        Feedback.forLongPress(context);
        _showGifSheet(
          context,
          url: tile.url,
          link: tile.url,
          favorite: tile.favorite,
        );
      },
      child: ClipRRect(
        borderRadius: context.neriSize.rounded(NeriRadiusRole.image),
        child: _GifImage(
          url: tile.previewUrl,
          animate: animate,
          onGone: forget
              ? () => ref.read(favoriteGifsProvider.notifier).remove(tile.url)
              : null,
        ),
      ),
    );
  }
}

Future<void> _showGifSheet(
  BuildContext context, {
  required String url,
  required FavoriteGif favorite,
  String? link,
}) => showSheet<void>(
  context,
  builder: (context) => Consumer(
    builder: (context, ref, _) {
      final saved = ref.watch(
        favoriteUrlsProvider.select((urls) => urls.contains(favorite.url)),
      );

      return SheetActions(
        actions: [
          SheetAction(
            icon: Symbols.star_rounded,
            filled: saved,
            dismiss: false,
            label: saved
                ? 'Remove from favorites'
                : 'Add to favorites', //TODO: add l10n
            onTap: () =>
                ref.read(favoriteGifsProvider.notifier).toggle(favorite),
          ),
          SheetAction(
            icon: Symbols.link_rounded,
            label: 'Copy GIF link', //TODO: add l10n
            onTap: () => Clipboard.setData(ClipboardData(text: url)),
          ),
          SheetAction(
            icon: Symbols.open_in_new_rounded,
            label: 'Open in browser', //TODO: add l10n
            onTap: () => openExternal(link ?? url),
          ),
        ],
      );
    },
  ),
);
