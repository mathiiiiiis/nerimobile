import 'package:drift/drift.dart';

@DataClassName('AnnouncementRow')
class Announcements extends Table {
  TextColumn get id => text()();
  TextColumn get payload => text()();
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DismissedAnnouncementRow')
class DismissedAnnouncements extends Table {
  TextColumn get id => text()();

  @override
  Set<Column> get primaryKey => {id};
}
