import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nerimobile/db/daos/favorite_gif_dao.dart';
import 'package:nerimobile/db/database.dart';
import 'package:nerimobile/models/gif.dart';

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
}
