import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nerimobile/models/user.dart';

final currentUserProvider = NotifierProvider<CurrentUserNotifier, User?>(
  CurrentUserNotifier.new,
);

final currentUserIdProvider = NotifierProvider<CurrentUserIdNotifier, String?>(
  CurrentUserIdNotifier.new,
);

final usersProvider = NotifierProvider<UsersNotifier, Map<String, User>>(
  UsersNotifier.new,
);

final userProvider = Provider.family<User?, String>(
  (ref, userId) => ref.watch(usersProvider.select((users) => users[userId])),
);

class CurrentUserNotifier extends Notifier<User?> {
  @override
  User? build() => null;

  void setCurrentUser(User? user) => state = user;

  void updateCurrentUser(Map<String, dynamic> updated) =>
      state = state?.merge(updated);
}

class CurrentUserIdNotifier extends Notifier<String?> {
  @override
  String? build() => ref.watch(currentUserProvider)?.id;

  void hydrate(String id) => state ??= id;
}

class UsersNotifier extends Notifier<Map<String, User>> {
  @override
  Map<String, User> build() => const {};

  void setUsers(List<User> list) =>
      state = {...state, for (final user in list) user.id: _filled(user)};

  void addUser(User user) => state = {...state, user.id: _filled(user)};

  void updateUser(String userId, Map<String, dynamic> updated) {
    final user = state[userId];
    if (user == null) return;
    state = {...state, userId: user.merge(updated)};
  }

  User _filled(User user) => switch (state[user.id]) {
    final known? => user.filledFrom(known),
    null => user,
  };
}
