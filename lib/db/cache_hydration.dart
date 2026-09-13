import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nerimobile/db/daos/channel_dao.dart';
import 'package:nerimobile/db/daos/inbox_dao.dart';
import 'package:nerimobile/db/daos/user_dao.dart';
import 'package:nerimobile/db/database.dart';
import 'package:nerimobile/stores/auth/auth_store.dart';
import 'package:nerimobile/stores/channel/channel_store.dart';
import 'package:nerimobile/stores/inbox/inbox_store.dart';
import 'package:nerimobile/stores/user/user_store.dart';

//hydrates dms before socket connects
final chacheHydrationProvider = FutureProvider<void>((ref) async {
  final token = await ref.watch(authProvider.future);
  if (token == null) return;

  final db = ref.read(databaseProvider);
  final users = await UserDao(db).all();
  final channels = await ChannelDao(db).all();
  final inboxes = await InboxDao(
    db,
  ).all({for (final user in users) user.id: user});

  //socket may have newer data
  if (ref.read(usersProvider).isEmpty) {
    ref.read(usersProvider.notifier).setUsers(users);
  }
  if (ref.read(channelsProvider).isEmpty) {
    ref.read(channelsProvider.notifier).addChannels(channels);
  }
  if (ref.read(inboxProvider).isEmpty) {
    ref.read(inboxProvider.notifier).setInbox(inboxes);
  }
});
