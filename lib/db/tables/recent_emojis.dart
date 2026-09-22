import 'package:drift/drift.dart';

@DataClassName('RecentEmojiRow')
class RecentEmojis extends Table {
  TextColumn get emoji => text()();
  IntColumn get usedAt => integer()();

  @override
  Set<Column> get primaryKey => {emoji};
}
