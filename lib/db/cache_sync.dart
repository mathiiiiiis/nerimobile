import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nerimobile/db/daos/channel_dao.dart';
import 'package:nerimobile/db/daos/inbox_dao.dart';
import 'package:nerimobile/db/daos/user_dao.dart';
import 'package:nerimobile/db/database.dart';
import 'package:nerimobile/stores/channel/channel_store.dart';
import 'package:nerimobile/stores/connection/connection_store.dart';
import 'package:nerimobile/stores/inbox/inbox_store.dart';
import 'package:nerimobile/stores/user/user_store.dart';

const _writeDelay = Duration(seconds: 1);

enum _Cached { channels, inboxes, users }

//batch write from busy channels
class CacheSync {
  CacheSync(this._ref) {
    _ref.listen(channelsProvider, (_, _) => _schedule(_Cached.channels));
    _ref.listen(inboxProvider, (_, _) => _schedule(_Cached.inboxes));
    _ref.listen(usersProvider, (_, _) => _schedule(_Cached.users));
  }

  final Ref _ref;
  final _dirty = <_Cached>{};
  Timer? _timer;

  //empty before auth ≠ empty
  bool get _trusted => _ref.read(connectionProvider) is Authenticated;

  void _schedule(_Cached what) {
    if (!_trusted) return;

    _dirty.add(what);
    _timer?.cancel();
    _timer = Timer(_writeDelay, _write);
  }

  Future<void> _write() async {
    final pending = _dirty.toSet();
    _dirty.clear();

    final db = _ref.read(databaseProvider);

    for (final what in pending) {
      switch (what) {
        case _Cached.channels:
          await ChannelDao(db).sync(_ref.read(channelsProvider).values);
        case _Cached.inboxes:
          await InboxDao(db).sync(_ref.read(inboxProvider).values);
        case _Cached.users:
          await UserDao(db).sync(_ref.read(usersProvider).values);
      }
    }
  }

  void dispose() => _timer?.cancel();
}

final cacheSyncProvider = Provider<CacheSync>((ref) {
  final sync = CacheSync(ref);
  ref.onDispose(sync.dispose);
  return sync;
});
