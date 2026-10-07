// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ordered_server_id_dao.dart';

// ignore_for_file: type=lint
mixin _$OrderedServerIdDaoMixin on DatabaseAccessor<NeriDatabase> {
  $OrderedServerIdsTable get orderedServerIds =>
      attachedDatabase.orderedServerIds;
  OrderedServerIdDaoManager get managers => OrderedServerIdDaoManager(this);
}

class OrderedServerIdDaoManager {
  final _$OrderedServerIdDaoMixin _db;
  OrderedServerIdDaoManager(this._db);
  $$OrderedServerIdsTableTableManager get orderedServerIds =>
      $$OrderedServerIdsTableTableManager(
        _db.attachedDatabase,
        _db.orderedServerIds,
      );
}
