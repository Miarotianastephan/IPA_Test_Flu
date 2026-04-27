// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dao.dart';

// ignore_for_file: type=lint
mixin _$UserDaoMixin on DatabaseAccessor<AppDatabase> {
  $UserInfosTable get userInfos => attachedDatabase.userInfos;
  UserDaoManager get managers => UserDaoManager(this);
}

class UserDaoManager {
  final _$UserDaoMixin _db;
  UserDaoManager(this._db);
  $$UserInfosTableTableManager get userInfos =>
      $$UserInfosTableTableManager(_db.attachedDatabase, _db.userInfos);
}
