// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_dao.dart';

// ignore_for_file: type=lint
mixin _$ConversationDaoMixin on DatabaseAccessor<AppDatabase> {
  $ConversationsTable get conversations => attachedDatabase.conversations;
  $ConversationUsersTable get conversationUsers =>
      attachedDatabase.conversationUsers;
  $UserInfosTable get userInfos => attachedDatabase.userInfos;
  $MessagesTable get messages => attachedDatabase.messages;
  $AgentSupportsTable get agentSupports => attachedDatabase.agentSupports;
  ConversationDaoManager get managers => ConversationDaoManager(this);
}

class ConversationDaoManager {
  final _$ConversationDaoMixin _db;
  ConversationDaoManager(this._db);
  $$ConversationsTableTableManager get conversations =>
      $$ConversationsTableTableManager(_db.attachedDatabase, _db.conversations);
  $$ConversationUsersTableTableManager get conversationUsers =>
      $$ConversationUsersTableTableManager(
        _db.attachedDatabase,
        _db.conversationUsers,
      );
  $$UserInfosTableTableManager get userInfos =>
      $$UserInfosTableTableManager(_db.attachedDatabase, _db.userInfos);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db.attachedDatabase, _db.messages);
  $$AgentSupportsTableTableManager get agentSupports =>
      $$AgentSupportsTableTableManager(_db.attachedDatabase, _db.agentSupports);
}
