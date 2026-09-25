import 'package:drift/drift.dart';

@DataClassName('FavoriteGifRow')
class FavoriteGifs extends Table {
  TextColumn get url => text()();
  TextColumn get previewUrl => text()();
  IntColumn get previewWidth => integer().nullable()();
  IntColumn get previewHeight => integer().nullable()();
  TextColumn get source => text()();
  IntColumn get savedAt => integer()();

  @override
  Set<Column> get primaryKey => {url};
}
