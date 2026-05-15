import 'package:nerimobile/models/user.dart';
import 'package:signals/signals_flutter.dart';

final userStore = UserStore();

class UserStore {
  final currentUser = Signal<User?>(null);
  final users = mapSignal<String, User>({});

  void setCurrentUser(User? user) => currentUser.value = user;

  void setUsers(List<User> list) {
    users.addAll({for (final u in list) u.id: u});
  }

  void addUser(User user) {
    users[user.id] = user;
  }
}
