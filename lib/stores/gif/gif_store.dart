import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nerimobile/models/gif.dart';
import 'package:nerimobile/services/api_client.dart';
import 'package:nerimobile/services/gif_service.dart';

//avoids repeated rate limited requests
final gifCategoriesProvider = FutureProvider<List<GifCategory>>((ref) {
  ref.keepAlive();
  return fetchGifCategories(ref.read(dioProvider));
});

final gifSearchProvider =
    AsyncNotifierProvider.family<GifSearchNotifier, GifResults, String>(
      GifSearchNotifier.new,
    );

class GifSearchNotifier extends AsyncNotifier<GifResults> {
  GifSearchNotifier(this.query);

  final String query;

  @override
  Future<GifResults> build() async {
    final page = await searchGifs(ref.read(dioProvider), query);
    return (gifs: page.gifs, next: page.next, loadingMore: false);
  }

  Future<void> loadMore() async {
    final current = state.value;
    final cursor = current?.next;
    if (current == null || cursor == null || current.loadingMore) return;

    state = AsyncData((gifs: current.gifs, next: cursor, loadingMore: true));

    try {
      final page = await searchGifs(ref.read(dioProvider), query, pos: cursor);
      state = AsyncData((
        gifs: [...current.gifs, ...page.gifs],
        next: page.next,
        loadingMore: false,
      ));
    } catch (_) {
      state = AsyncData((gifs: current.gifs, next: cursor, loadingMore: false));
    }
  }
}
