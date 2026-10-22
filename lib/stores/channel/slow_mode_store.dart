import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nerimobile/stores/channel/channel_store.dart';
import 'package:nerimobile/stores/server/server_permissions.dart';
import 'package:nerimobile/utils/permissions/role_permission_flag.dart';

final slowModeCooldownsProvider =
    NotifierProvider<SlowModeCooldowns, Map<String, int>>(
      SlowModeCooldowns.new,
    );

class SlowModeCooldowns extends Notifier<Map<String, int>> {
  final _timers = <String, Timer>{};

  @override
  Map<String, int> build() {
    ref.onDispose(() {
      for (final timer in _timers.values) {
        timer.cancel();
      }
    });
    return const {};
  }

  void start(String channelId, Duration wait) {
    _timers.remove(channelId)?.cancel();
    state = {
      ...state,
      channelId: DateTime.now().add(wait).millisecondsSinceEpoch,
    };
    _timers[channelId] = Timer(wait, () {
      _timers.remove(channelId);
      state = {...state}..remove(channelId);
    });
  }
}

typedef SlowMode = ({int seconds, int? until});

//null without, owners and admins skip it
final slowModeProvider = Provider.family<SlowMode?, String>((ref, channelId) {
  final channel = ref.watch(channelsProvider)[channelId];
  final seconds = channel?.slowModeSeconds;
  final serverId = channel?.serverId;
  if (seconds == null || seconds <= 0 || serverId == null) return null;

  final access = ref.watch(serverAccessProvider(serverId));
  if (access != null && memberHasPermission(access, RolePermissionFlag.admin)) {
    return null;
  }

  return (
    seconds: seconds,
    until: ref.watch(slowModeCooldownsProvider.select((c) => c[channelId])),
  );
});
