import 'package:nerimobile/models/user_presence.dart';
import 'package:signals/signals_flutter.dart';

final userPresenceStore = UserPresenceStore();

class UserPresenceStore {
  final presences = mapSignal<String, UserPresence>({});

  void addPresences(List<UserPresence> list) {
    presences.addAll({for (final u in list) u.userId: u});
  }

  void addPresence(UserPresence presence) {
    presences[presence.userId] = presence;
  }

  void updatePresence(String userId, Map<String, dynamic> payload) {
    if (payload["status"] != null && payload["status"] == 0) {
      presences.remove(userId);
    } else {
      presences[userId] = UserPresence(
        userId: userId,
        status: payload["status"],
      );
    }
  }
}
