import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nerimobile/models/user_presence.dart';

final presencesProvider =
    NotifierProvider<PresencesNotifier, Map<String, UserPresence>>(
      PresencesNotifier.new,
    );

class PresencesNotifier extends Notifier<Map<String, UserPresence>> {
  @override
  Map<String, UserPresence> build() => const {};

  void addPresences(List<UserPresence> list) =>
      state = {...state, for (final p in list) p.userId: p};

  void addPresence(UserPresence presence) =>
      state = {...state, presence.userId: presence};

  void updatePresence(String userId, Map<String, dynamic> payload) {
    if (payload['status'] == 0) {
      state = {...state}..remove(userId);
      return;
    }
    state = {
      ...state,
      userId: UserPresence(userId: userId, status: payload['status']),
    };
  }
}
