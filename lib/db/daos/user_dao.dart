import 'package:drift/drift.dart';

import 'package:nerimobile/db/database.dart';
import 'package:nerimobile/db/tables/users.dart';
import 'package:nerimobile/models/user.dart';

part 'user_dao.g.dart';

@DriftAccessor(tables: [Users])
class UserDao extends DatabaseAccessor<NeriDatabase> with _$UserDaoMixin {
  UserDao(super.attachedDatabase);

  Future<List<User>> all() async =>
      (await attachedDatabase.managers.users.get()).map(_model).toList();

  Future<void> sync(Iterable<User> list) =>
      batch((b) => b.insertAllOnConflictUpdate(users, list.map(_row)));
}

UsersCompanion _row(User user) => UsersCompanion.insert(
  id: user.id,
  username: user.username,
  hexColor: user.hexColor,
  avatar: Value(user.avatar),
);

User _model(UserRow row) => User(
  id: row.id,
  username: row.username,
  hexColor: row.hexColor,
  avatar: row.avatar,
);
