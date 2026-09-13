import 'package:drift/drift.dart';

import 'package:nerimobile/db/database.dart';
import 'package:nerimobile/db/tables/channels.dart';
import 'package:nerimobile/models/channel.dart';

part 'channel_dao.g.dart';

@DriftAccessor(tables: [Channels])
class ChannelDao extends DatabaseAccessor<NeriDatabase> with _$ChannelDaoMixin {
  ChannelDao(super.attachedDatabase);

  Future<List<Channel>> all() async =>
      (await attachedDatabase.managers.channels.get()).map(_model).toList();

  //socket == source of truth, meaning: not listed == gone
  Future<void> sync(Iterable<Channel> list) async {
    final ids = list.map((channel) => channel.id).toList();

    await transaction(() async {
      await (delete(channels)..where((t) => t.id.isNotIn(ids))).go();
      await batch((b) => b.insertAllOnConflictUpdate(channels, list.map(_row)));
    });
  }
}

ChannelsCompanion _row(Channel channel) => ChannelsCompanion.insert(
  id: channel.id,
  type: channel.type,
  name: Value(channel.name),
  order: Value(channel.order),
  serverId: Value(channel.serverId),
  icon: Value(channel.icon),
  categoryId: Value(channel.categoryId),
  lastMessagedAt: Value(channel.lastMessagedAt),
);

Channel _model(ChannelRow row) => Channel(
  id: row.id,
  type: row.type,
  name: row.name,
  order: row.order,
  serverId: row.serverId,
  icon: row.icon,
  categoryId: row.categoryId,
  lastMessagedAt: row.lastMessagedAt,
);
