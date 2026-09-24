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
    AsyncNotifierProvider.family<GifSearchNotifier, List<Gif>, String>(
      GifSearchNotifier.new,
    );

class GifSearchNotifier extends AsyncNotifier<List<Gif>> {
  GifSearchNotifier(this.query);

  final String query;

  @override
  Future<List<Gif>> build() async {
    final page = await searchGifs(ref.read(dioProvider), query);
    return page.gifs;
  }
}
