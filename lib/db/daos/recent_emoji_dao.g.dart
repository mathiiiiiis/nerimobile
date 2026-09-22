// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_emoji_dao.dart';

// ignore_for_file: type=lint
mixin _$RecentEmojiDaoMixin on DatabaseAccessor<NeriDatabase> {
  $RecentEmojisTable get recentEmojis => attachedDatabase.recentEmojis;
  RecentEmojiDaoManager get managers => RecentEmojiDaoManager(this);
}

class RecentEmojiDaoManager {
  final _$RecentEmojiDaoMixin _db;
  RecentEmojiDaoManager(this._db);
  $$RecentEmojisTableTableManager get recentEmojis =>
      $$RecentEmojisTableTableManager(_db.attachedDatabase, _db.recentEmojis);
}
