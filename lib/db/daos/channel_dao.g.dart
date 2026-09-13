// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_dao.dart';

// ignore_for_file: type=lint
mixin _$ChannelDaoMixin on DatabaseAccessor<NeriDatabase> {
  $ChannelsTable get channels => attachedDatabase.channels;
  ChannelDaoManager get managers => ChannelDaoManager(this);
}

class ChannelDaoManager {
  final _$ChannelDaoMixin _db;
  ChannelDaoManager(this._db);
  $$ChannelsTableTableManager get channels =>
      $$ChannelsTableTableManager(_db.attachedDatabase, _db.channels);
}
