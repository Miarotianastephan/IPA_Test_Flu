import 'package:drift/drift.dart';
import 'package:live_app/database/mappers.dart';

import '../../models/conversation_user.dart';
import '../../models/userinfo.dart';
import '../app_database.dart';
import '../tables.dart';

part 'conversation_user_dao.g.dart';

@DriftAccessor(tables: [ConversationUsers, UserInfos])
class ConversationUserDao extends DatabaseAccessor<AppDatabase>
    with _$ConversationUserDaoMixin {
  ConversationUserDao(super.db);

  /// 查询某个会话的所有成员，并且把 user 信息 join 进去
  Future<List<ConversationUser>> getUsersForConversation(
    int conversationId,
  ) async {
    final query = select(conversationUsers).join([
      leftOuterJoin(
        userInfos,
        userInfos.id.equalsExp(conversationUsers.userId),
      ),
    ])..where(conversationUsers.conversationId.equals(conversationId));

    final rows = await query.get();

    return rows.map((row) {
      final cu = row.readTable(conversationUsers);
      final user = row.readTableOrNull(userInfos);

      return ConversationUser(
        id: cu.id,
        conversationId: cu.conversationId,
        userId: cu.userId,
        agentSupportId: cu.agentSupportId,
        role: cu.role,
        joinedAt: cu.joinedAt,
        user: user,
      );
    }).toList();
  }

  /// 批量替换某个会话的成员（先删后插）
  Future<void> replaceConversationUsers(
    int conversationId,
    List<ConversationUser> users,
  ) async {
    await transaction(() async {
      // 删除旧的成员记录
      await (delete(
        conversationUsers,
      )..where((tbl) => tbl.conversationId.equals(conversationId))).go();

      // 插入新的成员记录（不包含 user 字段，只存 id / joinedAt / role）
      await batch((batch) {
        batch.insertAll(
          conversationUsers,
          users
              .map(
                (u) => ConversationUsersCompanion(
                  id: Value(u.id),
                  conversationId: Value(u.conversationId),
                  userId: Value(u.userId),
                  agentSupportId: Value(u.agentSupportId),
                  role: Value(u.role),
                  joinedAt: Value(u.joinedAt),
                ),
              )
              .toList(),
          mode: InsertMode.insertOrReplace,
        );
      });
    });
  }

  /// 可选：把成员里的 UserInfo 一并 upsert 到 UserInfos 表
  Future<void> upsertUsersInfoFromConversationUsers(
    List<ConversationUser> users,
  ) async {
    final userList = users.map((u) => u.user).whereType<UserInfo>().toList();

    if (userList.isEmpty) return;

    await batch((batch) {
      batch.insertAllOnConflictUpdate(
        userInfos,
        userList.map((u) => u.toCompanion()).toList(),
      );
    });
  }
}
