import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:live_app/database/mappers.dart';

import '../../models/conversation.dart';
import '../../models/conversation_user.dart';
import '../../models/message.dart';
import '../app_database.dart';
import '../tables.dart';

part 'conversation_dao.g.dart';

@DriftAccessor(tables: [Conversations, ConversationUsers, UserInfos, Messages])
class ConversationDao extends DatabaseAccessor<AppDatabase>
    with _$ConversationDaoMixin {
  ConversationDao(super.db);

  // 基础 upsert（用于会话列表） 只更新 conversations 表，不改 users/messages
  Future<void> upsertBasic(Conversation conv) async {
    await into(conversations).insertOnConflictUpdate(conv.toCompanion());
  }

  // 完整 upsert（用于聊天详情） 会话 + users + userInfo + lastMessage
  Future<void> upsertFull(Conversation conv) async {
    await transaction(() async {
      //会话
      await into(conversations).insertOnConflictUpdate(conv.toCompanion());

      //用户列表
      for (final cu in conv.users) {
        await into(conversationUsers).insertOnConflictUpdate(
          ConversationUsersCompanion(
            id: Value(cu.id),
            conversationId: Value(cu.conversationId),
            userId: Value(cu.userId),
            joinedAt: Value(cu.joinedAt),
          ),
        );

        // userInfo
        if (cu.user != null) {
          await into(userInfos).insertOnConflictUpdate(cu.user!.toCompanion());
        }
      }

      //最后一条消息（若有）
      if (conv.lastMessage != null) {
        await into(
          messages,
        ).insertOnConflictUpdate(conv.lastMessage!.toCompanion());
      }
    });
  }

  // 更新会话未读数量
  Future<void> updateUnreadCount(int conversationId, int unreadCount) async {
    await (update(conversations)..where((tbl) => tbl.id.equals(conversationId)))
        .write(ConversationsCompanion(unreadCount: Value(unreadCount)));
  }

  // 获取完整会话
  Future<List<Conversation>> getAllFull() async {
    final convList = await select(conversations).get();
    List<Conversation> result = [];

    for (final c in convList) {
      // 查询用户
      final cuRows =
          await (select(
            conversationUsers,
          )..where((tbl) => tbl.conversationId.equals(c.id))).join([
            leftOuterJoin(
              userInfos,
              userInfos.id.equalsExp(conversationUsers.userId),
            ),
          ]).get();

      final users = cuRows.map((row) {
        final cu = row.readTable(conversationUsers);
        final ui = row.readTableOrNull(userInfos);
        return ConversationUser(
          id: cu.id,
          conversationId: cu.conversationId,
          userId: cu.userId,
          joinedAt: cu.joinedAt,
          user: ui,
        );
      }).toList();

      // 最后一条消息
      Message? lastMsg;
      if (c.lastMessageId != null) {
        lastMsg = await (select(
          messages,
        )..where((tbl) => tbl.id.equals(c.lastMessageId!))).getSingleOrNull();
      }

      result.add(c.copyWith(users: users, lastMessage: lastMsg));
    }

    return result;
  }

  // 根据 peerUser 找会话
  Future<Conversation?> getFullByPeerUser(int peerId) async {
    final cu =
        await (select(conversationUsers)
              ..where((tbl) => tbl.userId.equals(peerId))
              ..limit(1))
            .getSingleOrNull();

    if (cu == null) return null;

    return getFullById(cu.conversationId);
  }

  Future<Conversation?> getFullById(int convId) async {
    final list = await getAllFull();
    return list.firstWhereOrNull((e) => e.id == convId);
  }
}
