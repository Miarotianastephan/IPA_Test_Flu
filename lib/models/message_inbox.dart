import 'package:json_annotation/json_annotation.dart';

import '../utils/json_utils.dart';
import 'conversation.dart';
import 'message.dart';

part 'message_inbox.g.dart';

@JsonSerializable(explicitToJson: true)
class MessageInbox {
  @JsonKey(name: "id", fromJson: parseInt)
  final int id;

  @JsonKey(name: "user_id")
  final String userId;

  @JsonKey(name: "message_id", fromJson: parseInt)
  final int messageId;

  @JsonKey(name: "conversation_id", fromJson: parseInt)
  final int conversationId;

  @JsonKey(name: "is_read", fromJson: parseBool)
  final bool isRead;

  @JsonKey(name: "is_deleted", fromJson: parseBool)
  final bool isDeleted;

  @JsonKey(name: "pinned", fromJson: parseBool)
  final bool pinned;

  @JsonKey(name: "created_at")
  final String createdAt;

  /// 消息本体
  @JsonKey(name: "message")
  final Message? message;

  /// 会话信息（后端返回）
  @JsonKey(name: "conversation")
  final Conversation? conversation;

  MessageInbox({
    required this.id,
    required this.userId,
    required this.messageId,
    required this.conversationId,
    required this.isRead,
    required this.isDeleted,
    required this.pinned,
    required this.createdAt,
    this.message,
    this.conversation,
  });

  factory MessageInbox.fromJson(Map<String, dynamic> json) =>
      _$MessageInboxFromJson(json);

  Map<String, dynamic> toJson() => _$MessageInboxToJson(this);
}
