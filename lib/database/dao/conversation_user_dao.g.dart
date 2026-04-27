// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_user_dao.dart';

// ignore_for_file: type=lint
mixin _$ConversationUserDaoMixin on DatabaseAccessor<AppDatabase> {
  $ConversationUsersTable get conversationUsers =>
      attachedDatabase.conversationUsers;
  $UserInfosTable get userInfos => attachedDatabase.userInfos;
  ConversationUserDaoManager get managers => ConversationUserDaoManager(this);
}

class ConversationUserDaoManager {
  final _$ConversationUserDaoMixin _db;
  ConversationUserDaoManager(this._db);
  $$ConversationUsersTableTableManager get conversationUsers =>
      $$ConversationUsersTableTableManager(
        _db.attachedDatabase,
        _db.conversationUsers,
      );
  $$UserInfosTableTableManager get userInfos =>
      $$UserInfosTableTableManager(_db.attachedDatabase, _db.userInfos);
}
