import 'package:drift/drift.dart';
import 'package:live_app/database/mappers.dart';

import '../../models/userinfo.dart';
import '../app_database.dart';
import '../tables.dart';

part 'user_dao.g.dart';

@DriftAccessor(tables: [UserInfos])
class UserDao extends DatabaseAccessor<AppDatabase> with _$UserDaoMixin {
  UserDao(super.db);

  Future<UserInfo?> getUser(String id) async {
    return await (select(
      userInfos,
    )..where((u) => u.id.equals(id))).getSingleOrNull();
  }

  Future<void> insertUser(UserInfo user) =>
      into(userInfos).insert(user.toCompanion());

  Future<void> updateUser(UserInfo user) =>
      update(userInfos).replace(user.toCompanion());
}
