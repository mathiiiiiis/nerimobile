// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement_dao.dart';

// ignore_for_file: type=lint
mixin _$AnnouncementDaoMixin on DatabaseAccessor<NeriDatabase> {
  $AnnouncementsTable get announcements => attachedDatabase.announcements;
  $DismissedAnnouncementsTable get dismissedAnnouncements =>
      attachedDatabase.dismissedAnnouncements;
  AnnouncementDaoManager get managers => AnnouncementDaoManager(this);
}

class AnnouncementDaoManager {
  final _$AnnouncementDaoMixin _db;
  AnnouncementDaoManager(this._db);
  $$AnnouncementsTableTableManager get announcements =>
      $$AnnouncementsTableTableManager(_db.attachedDatabase, _db.announcements);
  $$DismissedAnnouncementsTableTableManager get dismissedAnnouncements =>
      $$DismissedAnnouncementsTableTableManager(
        _db.attachedDatabase,
        _db.dismissedAnnouncements,
      );
}
