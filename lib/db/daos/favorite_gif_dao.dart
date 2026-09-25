import 'package:drift/drift.dart';

import 'package:nerimobile/db/database.dart';
import 'package:nerimobile/db/tables/favorite_gifs.dart';
import 'package:nerimobile/models/gif.dart';

part 'favorite_gif_dao.g.dart';

@DriftAccessor(tables: [FavoriteGifs])
class FavoriteGifDao extends DatabaseAccessor<NeriDatabase>
    with _$FavoriteGifDaoMixin {
  FavoriteGifDao(super.attachedDatabase);

  Future<List<FavoriteGif>> all() async {
    final rows =
        await (select(favoriteGifs)..orderBy([
              (row) => OrderingTerm(
                expression: row.savedAt,
                mode: OrderingMode.desc,
              ),
            ]))
            .get();

    return [for (final row in rows) _favorite(row)];
  }

  Future<void> add(FavoriteGif gif) => into(favoriteGifs).insert(
    FavoriteGifsCompanion.insert(
      url: gif.url,
      previewUrl: gif.previewUrl,
      previewWidth: Value(gif.previewWidth),
      previewHeight: Value(gif.previewHeight),
      source: gif.source.name,
      savedAt: gif.savedAt,
    ),
    mode: InsertMode.insertOrReplace,
  );

  Future<void> remove(String url) =>
      (delete(favoriteGifs)..where((row) => row.url.equals(url))).go();
}

FavoriteGif _favorite(FavoriteGifRow row) => FavoriteGif(
  url: row.url,
  previewUrl: row.previewUrl,
  previewWidth: row.previewWidth,
  previewHeight: row.previewHeight,
  source: GifSource.values.firstWhere(
    (source) => source.name == row.source,
    orElse: () => GifSource.other,
  ),
  savedAt: row.savedAt,
);
