// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_gif_dao.dart';

// ignore_for_file: type=lint
mixin _$FavoriteGifDaoMixin on DatabaseAccessor<NeriDatabase> {
  $FavoriteGifsTable get favoriteGifs => attachedDatabase.favoriteGifs;
  FavoriteGifDaoManager get managers => FavoriteGifDaoManager(this);
}

class FavoriteGifDaoManager {
  final _$FavoriteGifDaoMixin _db;
  FavoriteGifDaoManager(this._db);
  $$FavoriteGifsTableTableManager get favoriteGifs =>
      $$FavoriteGifsTableTableManager(_db.attachedDatabase, _db.favoriteGifs);
}
