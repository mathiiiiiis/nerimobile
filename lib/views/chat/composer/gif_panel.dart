import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:nerimobile/models/gif.dart';
import 'package:nerimobile/stores/composer/composer_store.dart';
import 'package:nerimobile/stores/gif/gif_store.dart';
import 'package:nerimobile/stores/window/window_focus_store.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';
import 'package:nerimobile/utils/caches.dart';
import 'package:nerimobile/utils/image.dart';
import 'package:nerimobile/views/app_text_field.dart';
import 'package:nerimobile/views/empty_state.dart';
import 'package:nerimobile/views/skeleton/skeleton.dart';

const _columns = 2;
const _tileRatio = 16 / 9;
const _skeletonTiles = 6;
const _scrimOpacity = 0.65;
const _scrimStop = 0.55;
const _creditHeight = 14.0;
const _searchHeight = 34.0;
const _resultRow = 110.0;
const _debounce = Duration(milliseconds: 350);
const _flexScale = 1000;

typedef _Row = ({List<Gif> gifs, double height, bool justified});

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

  @override
  void initState() {
    super.initState();
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

  void _pick(Gif gif) {
    _searchFocus.unfocus();
    ref
        .read(composerProvider(widget.channelId).notifier)
        .insert('${gif.gifUrl} ');
    widget.onPicked();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: _query.isEmpty
              ? _CategoryBody(onPick: _searchFor)
              : _ResultBody(query: _query, onPick: _pick),
        ),
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
  const _CategoryBody({required this.onPick});

  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(gifCategoriesProvider);

    return switch (categories) {
      AsyncData(:final value) when value.isNotEmpty => _Categories(
        categories: value,
        onPick: onPick,
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
  final ValueChanged<Gif> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(gifSearchProvider(query));

    return switch (results) {
      AsyncData(:final value) when value.isNotEmpty => _Results(
        gifs: value,
        onPick: onPick,
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

Widget _pinned(BuildContext context, Widget child) => Column(
  spacing: context.neriSize.space(NeriSpacingRole.sm),
  children: [
    Expanded(
      child: Padding(
        padding: EdgeInsets.only(top: _searchInset(context)),
        child: child,
      ),
    ),
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
  const _Categories({required this.categories, required this.onPick});

  final List<GifCategory> categories;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final gap = context.neriSize.space(NeriSpacingRole.sm);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.only(top: _searchInset(context)),
          sliver: SliverGrid.builder(
            gridDelegate: _grid(context),
            itemCount: categories.length,
            itemBuilder: (context, index) => _CategoryTile(
              category: categories[index],
              onTap: () => onPick(categories[index].searchTerm),
            ),
          ),
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
  const _CategoryTile({required this.category, required this.onTap});

  final GifCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;

    return LayoutBuilder(
      builder: (context, constraints) => GestureDetector(
        onTap: onTap,
        child: ClipRRect(
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

class _Results extends StatelessWidget {
  const _Results({required this.gifs, required this.onPick});

  final List<Gif> gifs;
  final ValueChanged<Gif> onPick;

  @override
  Widget build(BuildContext context) {
    final gap = context.neriSize.space(NeriSpacingRole.sm);

    return LayoutBuilder(
      builder: (context, constraints) {
        final rows = _rows(gifs, width: constraints.maxWidth, gap: gap);
        return ListView.separated(
          padding: EdgeInsets.only(top: _searchInset(context)),
          itemCount: rows.length + 1,
          separatorBuilder: (context, index) => SizedBox(height: gap),
          itemBuilder: (context, index) => index == rows.length
              ? const Center(child: _Credit())
              : _ResultRow(row: rows[index], gap: gap, onPick: onPick),
        );
      },
    );
  }
}

List<_Row> _rows(List<Gif> gifs, {required double width, required double gap}) {
  final rows = <_Row>[];
  var row = <Gif>[];
  var ratios = 0.0;

  for (final gif in gifs) {
    row.add(gif);
    ratios += gif.ratio;

    final height = (width - gap * (row.length - 1)) / ratios;
    if (height > _resultRow) continue;

    rows.add((gifs: row, height: height, justified: true));
    row = [];
    ratios = 0;
  }

  if (row.isNotEmpty) {
    final height = (width - gap * (row.length - 1)) / ratios;
    rows.add((gifs: row, height: min(height, _resultRow), justified: false));
  }

  return rows;
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.row,
    required this.gap,
    required this.onPick,
  });

  final _Row row;
  final double gap;
  final ValueChanged<Gif> onPick;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: row.height,
    child: Row(
      spacing: gap,
      children: [
        for (final gif in row.gifs)
          if (row.justified)
            Expanded(
              flex: (gif.ratio * _flexScale).round(),
              child: _ResultTile(gif: gif, onTap: () => onPick(gif)),
            )
          else
            SizedBox(
              width: row.height * gif.ratio,
              child: _ResultTile(gif: gif, onTap: () => onPick(gif)),
            ),
      ],
    ),
  );
}

class _ResultTile extends ConsumerWidget {
  const _ResultTile({required this.gif, required this.onTap});

  final Gif gif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.neri;
    final animate = ref.watch(windowFocusProvider);

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: context.neriSize.rounded(NeriRadiusRole.image),
        child: CachedNetworkImage(
          imageUrl: proxiedGifUrl(gif.previewUrl, animate: animate),
          cacheManager: mediaCache,
          fit: BoxFit.cover,
          fadeInDuration: Duration.zero,
          fadeOutDuration: Duration.zero,
          useOldImageOnUrlChange: true,
          placeholder: (_, _) => const SkeletonScope(
            child: SkeletonBlock(height: double.infinity),
          ),
          errorWidget: (_, _, _) => ColoredBox(color: colors[NeriToken.card]),
        ),
      ),
    );
  }
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
