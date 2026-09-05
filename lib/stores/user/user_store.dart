import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nerimobile/models/user.dart';

final currentUserProvider = NotifierProvider<CurrentUserNotifier, User?>(
  CurrentUserNotifier.new,
);

final usersProvider = NotifierProvider<UsersNotifier, Map<String, User>>(
  UsersNotifier.new,
);

class CurrentUserNotifier extends Notifier<User?> {
  @override
  User? build() => null;

  void setCurrentUser(User? user) => state = user;
}

class UsersNotifier extends Notifier<Map<String, User>> {
  @override
  Map<String, User> build() => const {};

  void setUsers(List<User> list) =>
      state = {...state, for (final user in list) user.id: user};

  void addUser(User user) => state = {...state, user.id: user};
}
