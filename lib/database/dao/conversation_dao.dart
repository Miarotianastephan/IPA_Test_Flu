import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:live_app/database/mappers.dart';

import '../../models/conversation.dart';
import '../../models/conversation_user.dart';
import '../../models/message.dart';
import '../app_database.dart';
import '../tables.dart';

part 'conversation_dao.g.dart';

@DriftAccessor(
  tables: [Conversations, ConversationUsers, UserInfos, Messages, AgentSupports],
)
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

      // 删除不再存在的成员（同步服务器状态）
      final currentIds = conv.users.map((u) => u.effectiveId).toSet();
      final existingUsers = await (select(
        conversationUsers,
      )..where((tbl) => tbl.conversationId.equals(conv.id))).get();

      for (final existing in existingUsers) {
        if (!currentIds.contains(existing.effectiveId)) {
          await (delete(
            conversationUsers,
          )..where((tbl) => tbl.id.equals(existing.id))).go();
        }
      }

      //用户列表
      for (final cu in conv.users) {
        await into(conversationUsers).insertOnConflictUpdate(
          ConversationUsersCompanion(
            id: Value(cu.id),
            conversationId: Value(cu.conversationId),
            userId: Value(cu.userId),
            agentSupportId: Value(cu.agentSupportId),
            role: Value(cu.role),
            joinedAt: Value(cu.joinedAt),
          ),
        );

        // userInfo
        if (cu.user != null) {
          await into(userInfos).insertOnConflictUpdate(cu.user!.toCompanion());
        }

        // agentSupport
        if (cu.agentSupport != null) {
          await into(agentSupports).insertOnConflictUpdate(
            cu.agentSupport!.toCompanion(),
          );
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

  // 删除会话中的特定用户
  Future<void> removeUserFromConversation(
    int conversationId,
    String userId,
  ) async {
    await (delete(conversationUsers)..where(
          (tbl) =>
              tbl.conversationId.equals(conversationId) &
              tbl.userId.equals(userId),
        ))
        .go();
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
            leftOuterJoin(
              agentSupports,
              agentSupports.id.equalsExp(conversationUsers.agentSupportId),
            ),
          ]).get();

      final users = cuRows.map((row) {
        final cu = row.readTable(conversationUsers);
        final ui = row.readTableOrNull(userInfos);
        return ConversationUser(
          id: cu.id,
          conversationId: cu.conversationId,
          userId: cu.userId,
          agentSupportId: cu.agentSupportId,
          role: cu.role,
          joinedAt: cu.joinedAt,
          user: ui,
          agentSupport: row.readTableOrNull(agentSupports),
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

  // 根据 peerUser 找会话 (checks both userId and agentSupportId)
  Future<Conversation?> getFullByPeerUser(String peerId) async {
    // Find single (P2P) conversations where the peer is a member
    // (either as a regular user via userId or as a support agent via agentSupportId)
    final query =
        select(conversationUsers).join([
          innerJoin(
            conversations,
            conversations.id.equalsExp(conversationUsers.conversationId),
          ),
        ])..where(
          (conversationUsers.userId.equals(peerId) |
                  conversationUsers.agentSupportId.equals(peerId)) &
              conversations.type.equals('single'),
        );

    final results = await query.get();

    if (results.isEmpty) return null;

    final conversationId = results.first
        .readTable(conversationUsers)
        .conversationId;

    return getFullById(conversationId);
  }

  Future<Conversation?> getFullById(int convId) async {
    final list = await getAllFull();
    return list.firstWhereOrNull((e) => e.id == convId);
  }
}
