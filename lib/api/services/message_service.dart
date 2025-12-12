import 'package:live_app/models/conversation.dart';
import 'package:live_app/models/message.dart';
import 'package:live_app/models/message_inbox.dart';
import 'package:live_app/models/page_response.dart';

import '../../models/api_response.dart';
import '../message_api.dart';
import 'base_service.dart';

class MessageService extends BaseService {
  MessageService(super.client);

  /// 获取未读消息数量（私聊 + 群聊）
  Future<ApiResponse<int>> getUnreadCount() {
    return post<int>(MessageApi.unreadCount, fromJson: (json) => json as int);
  }

  /// 获取未读消息列表
  Future<ApiResponse<PageResponse<MessageInbox>>> getUnreadList({
    required int page,
    required int limit,
  }) {
    return post<PageResponse<MessageInbox>>(
      MessageApi.unreadList,
      body: {"page": page, "limit": limit},
      fromJson: (json) =>
          PageResponse.fromJson(json, (item) => MessageInbox.fromJson(item)),
    );
  }

  /// 获取历史消息
  Future<ApiResponse<PageResponse<Message>>> getHistory({
    required int conversationId,
    required int page,
    required int limit,
  }) {
    return post<PageResponse<Message>>(
      MessageApi.history,
      body: {"id": conversationId, "page": page, "limit": limit},
      fromJson: (json) =>
          PageResponse.fromJson(json, (item) => Message.fromJson(item)),
    );
  }

  /// 清除历史消息
  Future<ApiResponse<String>> clearHistory({required int conversationId}) {
    return post<String>(
      MessageApi.historyClear,
      body: {"id": conversationId},
      fromJson: (json) => json.toString(),
    );
  }

  /// 标记消息为已读
  Future<ApiResponse<String>> markAsRead({
    List<int>? messageIDs,
    int? conversationId,
    bool isGroup = false,
  }) {
    return post<String>(
      MessageApi.read,
      body: {
        "message_ids": messageIDs,
        "conversation_id": conversationId,
        "is_group": isGroup,
      },
      fromJson: (json) => json.toString(),
    );
  }

  /// 撤回消息
  Future<ApiResponse<int>> revokeMessage(int messageId) {
    return post<int>(
      MessageApi.revoke,
      body: {"id": messageId},
      fromJson: (json) => json as int,
    );
  }

  /// 获取我的所有会话
  Future<ApiResponse<PageResponse<Conversation>>> getMyConversations({
    required int page,
    required int limit,
    String? keyword,
  }) {
    return post<PageResponse<Conversation>>(
      MessageApi.conversationList,
      body: {"page": page, "limit": limit, "keyword": keyword},
      fromJson: (json) =>
          PageResponse.fromJson(json, (item) => Conversation.fromJson(item)),
    );
  }

  /// 获取与某用户的单聊会话（不存在则创建）
  Future<ApiResponse<Conversation>> getConversationBetween(int userId) {
    return post<Conversation>(
      MessageApi.conversationBetween,
      body: {"id": userId.toString(), "type": "single"},
      fromJson: (json) => Conversation.fromJson(json),
    );
  }

  /// 通过MessageId 获取 会话
  Future<ApiResponse<Conversation>> getConversationByMessageId(int messageId) {
    return post<Conversation>(
      MessageApi.conversationByMessageId,
      body: {"id": messageId},
      fromJson: (json) => Conversation.fromJson(json),
    );
  }

  /// 创建群聊
  Future<ApiResponse<dynamic>> createGroup({
    required String name,
    required List<int> userIds,
  }) {
    return post<dynamic>(
      MessageApi.groupCreate,
      body: {"name": name, "user_ids": userIds},
      fromJson: (json) => json,
    );
  }

  /// 加入群聊
  Future<ApiResponse<String>> joinGroup(int conversationId) {
    return post<String>(
      MessageApi.groupJoin,
      body: {"id": conversationId},
      fromJson: (json) => json.toString(),
    );
  }

  /// 解散群聊（群主）
  Future<ApiResponse<String>> dissolveGroup(int conversationId) {
    return post<String>(
      MessageApi.groupDissolve,
      body: {"id": conversationId},
      fromJson: (json) => json.toString(),
    );
  }

  /// 转移群主
  Future<ApiResponse<String>> transferGroupOwner({
    required int conversationId,
    required int newOwnerId,
  }) {
    return post<String>(
      MessageApi.groupTransferOwner,
      body: {"conversation_id": conversationId, "new_owner_id": newOwnerId},
      fromJson: (json) => json.toString(),
    );
  }

  /// 退出群聊
  Future<ApiResponse<String>> leaveGroup(int conversationId) {
    return post<String>(
      MessageApi.groupLeave,
      body: {"id": conversationId},
      fromJson: (json) => json.toString(),
    );
  }

  /// 踢用户出群
  Future<ApiResponse<String>> kickUser({
    required int conversationId,
    required int targetUserId,
  }) {
    return post<String>(
      MessageApi.groupKick,
      body: {"conversation_id": conversationId, "target_user_id": targetUserId},
      fromJson: (json) => json.toString(),
    );
  }

  /// 发送聊天信息
  Future<ApiResponse<Message>> sendMessage({
    required int conversationId,
    required String toUserId,
    required String content,
    String messageType = "text",
    required bool isGroup,
  }) {
    return post<Message>(
      MessageApi.sendMessage,
      body: {
        "conversation_id": conversationId,
        "to_user_id": toUserId,
        "content": content,
        "message_type": messageType,
        "is_group": isGroup,
      },
      fromJson: (json) => Message.fromJson(json),
    );
  }
}
