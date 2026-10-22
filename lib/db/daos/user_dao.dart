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
  tag: Value(user.tag),
  hexColor: user.hexColor,
  avatar: Value(user.avatar),
  banner: Value(user.banner),
  badges: Value(user.badges),
  font: Value(user.profile?.font),
);

User _model(UserRow row) => User(
  id: row.id,
  username: row.username,
  tag: row.tag,
  hexColor: row.hexColor,
  avatar: row.avatar,
  banner: row.banner,
  badges: row.badges,
  profile: row.font == null ? null : Profile(font: row.font),
);
