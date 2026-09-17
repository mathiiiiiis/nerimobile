import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

const _expiry = Duration(seconds: 5);

final typingProvider =
    NotifierProvider<TypingNotifier, Map<String, List<String>>>(
      TypingNotifier.new,
    );

class TypingNotifier extends Notifier<Map<String, List<String>>> {
  final _timers = <String, Timer>{};

  @override
  Map<String, List<String>> build() {
    ref.onDispose(clear);
    return const {};
  }

  List<String> inChannel(String channelId) => state[channelId] ?? const [];

  void started(String channelId, String userId) {
    _timers['$channelId:$userId']?.cancel();
    _timers['$channelId:$userId'] = Timer(
      _expiry,
      () => stopped(channelId, userId),
    );

    final users = inChannel(channelId);
    if (users.contains(userId)) return;
    state = {
      ...state,
      channelId: [...users, userId],
    };
  }

  void stopped(String channelId, String userId) {
    _timers.remove('$channelId:$userId')?.cancel();

    final users = inChannel(channelId);
    if (!users.contains(userId)) return;

    final left = users.where((id) => id != userId).toList();
    state = {...state}
      ..remove(channelId)
      ..addAll(left.isEmpty ? const {} : {channelId: left});
  }

  void clear() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    state = const {};
  }
}
