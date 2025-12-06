import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/database/mappers.dart';

import '../../models/message.dart';
import '../../provider/current_user_provider.dart';
import '../app_database.dart';
import '../tables.dart';

part 'message_dao.g.dart';

@DriftAccessor(tables: [Messages])
class MessageDao extends DatabaseAccessor<AppDatabase> with _$MessageDaoMixin {
  MessageDao(super.db);

  Future<List<Message>> getMessages(int conversationId) {
    return (select(messages)
          ..where((m) => m.conversationId.equals(conversationId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Stream<List<Message>> watchMessages(int conversationId) {
    return (select(messages)
          ..where((m) => m.conversationId.equals(conversationId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  Future<void> insertMessage(Message msg) =>
      into(messages).insertOnConflictUpdate(msg.toCompanion());

  Future<Message?> getMessageById(int id) {
    return (select(messages)..where((m) => m.id.equals(id))).getSingleOrNull();
  }

  Future<void> updateMessageRead(int messageId, bool isRead) async {
    await (update(messages)..where((m) => m.id.equals(messageId))).write(
      MessagesCompanion(isRead: Value(isRead)),
    );
  }

  Future<void> deleteMessage(int id) async {
    await (delete(messages)..where((m) => m.id.equals(id))).go();
  }

  Future<void> deleteMessagesByConversation(int conversationId) async {
    await (delete(
      messages,
    )..where((m) => m.conversationId.equals(conversationId))).go();
  }

  Future<void> replaceTempMessage(int tempId, Message newMsg) async {
    // 删除临时消息
    await deleteMessage(tempId);

    // 插入真实服务端消息
    await insertMessage(newMsg);
  }

  Future<void> updateMessageSendState(
    int id, {
    required bool sendFailed,
  }) async {
    await (update(messages)..where((m) => m.id.equals(id))).write(
      MessagesCompanion(sendFailed: Value(sendFailed)),
    );
  }

  Future<void> deleteAllMessages() async {
    await delete(messages).go();
  }
}

@Deprecated('Create MessageDao directly from currentUserDatabaseProvider')
final messageDaoProvider = Provider<MessageDao>((ref) {
  final db = ref.watch(currentUserDatabaseProvider);
  return MessageDao(db);
});
