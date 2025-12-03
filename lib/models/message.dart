
import 'package:json_annotation/json_annotation.dart';

import '../utils/json_utils.dart';
import 'message_attachment.dart'; // attachments
import 'userinfo.dart'; // sender

part 'message.g.dart';

@JsonSerializable(explicitToJson: true)
class Message {
  @JsonKey(fromJson: parseInt)
  final int id;

  @JsonKey(name: "conversation_id", fromJson: parseInt)
  final int conversationId;

  @JsonKey(name: "sender_id", fromJson: parseInt)
  final int senderId;

  final String content;

  @JsonKey(name: "message_type")
  final String messageType;

  @JsonKey(name: "is_revoked")
  final bool isRevoked;

  @JsonKey(name: "revoked_at")
  final DateTime? revokedAt;

  @JsonKey(name: "created_at")
  final DateTime createdAt;

  /// 后端返回的发送者信息
  final UserInfo? sender;

  /// 后端返回的附件
  final List<MessageAttachment>? attachments;

  @JsonKey(name: "is_self")
  final bool isSelf;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final bool sendFailed;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final bool resending;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final bool isRead;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.messageType,
    required this.isRevoked,
    this.revokedAt,
    required this.createdAt,
    this.sender,
    this.attachments,
    this.isSelf = false,
    this.sendFailed = false,
    this.resending = false,
    this.isRead = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);

  Message copyWith({
    int? id,
    int? conversationId,
    int? senderId,
    String? content,
    String? messageType,
    bool? isRevoked,
    DateTime? revokedAt,
    DateTime? createdAt,
    UserInfo? sender,
    List<MessageAttachment>? attachments,
    bool? isSelf,
    bool? sendFailed,
    bool? resending,
    bool? isRead,
  }) => Message(
    id: id ?? this.id,
    conversationId: conversationId ?? this.conversationId,
    senderId: senderId ?? this.senderId,
    content: content ?? this.content,
    messageType: messageType ?? this.messageType,
    isRevoked: isRevoked ?? this.isRevoked,
    revokedAt: revokedAt ?? this.revokedAt,
    createdAt: createdAt ?? this.createdAt,
    sender: sender ?? this.sender,
    attachments: attachments ?? this.attachments,
    isSelf: isSelf ?? this.isSelf,
    sendFailed: sendFailed ?? this.sendFailed,
    resending: resending ?? this.resending,
    isRead: isRead ?? this.isRead,
  );
}
