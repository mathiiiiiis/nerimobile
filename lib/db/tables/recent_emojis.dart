import 'package:drift/drift.dart';

@DataClassName('RecentEmojiRow')
class RecentEmojis extends Table {
  TextColumn get emoji => text()();
  BoolColumn get custom => boolean().withDefault(const Constant(false))();
  IntColumn get usedAt => integer()();

  @override
  Set<Column> get primaryKey => {emoji};
}
