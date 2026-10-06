import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nerimobile/db/daos/favorite_gif_dao.dart';
import 'package:nerimobile/db/database.dart';
import 'package:nerimobile/models/gif.dart';

final favoriteGifsProvider =
    AsyncNotifierProvider<FavoriteGifNotifier, List<FavoriteGif>>(
      FavoriteGifNotifier.new,
    );

final favoriteUrlsProvider = Provider<Set<String>>((ref) {
  final favorites = ref.watch(favoriteGifsProvider).value ?? const [];
  return {for (final gif in favorites) gif.url};
});

class FavoriteGifNotifier extends AsyncNotifier<List<FavoriteGif>> {
  FavoriteGifDao get _dao => FavoriteGifDao(ref.read(databaseProvider));

  @override
  Future<List<FavoriteGif>> build() => _dao.all();

  Future<void> add(FavoriteGif gif) async {
    await _dao.add(gif);
    state = AsyncData(await _dao.all());
  }

  Future<void> remove(String url) async {
    await _dao.remove(url);
    state = AsyncData(await _dao.all());
  }

  Future<void> toggle(FavoriteGif gif) async {
    final saved = (await future).any((saved) => saved.url == gif.url);
    await (saved ? remove(gif.url) : add(gif));
  }
}
