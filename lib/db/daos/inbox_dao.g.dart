// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox_dao.dart';

// ignore_for_file: type=lint
mixin _$InboxDaoMixin on DatabaseAccessor<NeriDatabase> {
  $InboxesTable get inboxes => attachedDatabase.inboxes;
  InboxDaoManager get managers => InboxDaoManager(this);
}

class InboxDaoManager {
  final _$InboxDaoMixin _db;
  InboxDaoManager(this._db);
  $$InboxesTableTableManager get inboxes =>
      $$InboxesTableTableManager(_db.attachedDatabase, _db.inboxes);
}
