// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
  id: parseInt(json['id']),
  conversationId: parseInt(json['conversation_id']),
  senderId: json['sender_id'] as String?,
  senderSupportId: json['sender_support_id'] as String?,
  content: json['content'] as String,
  messageType: json['message_type'] as String,
  isRevoked: json['is_revoked'] as bool,
  revokedAt: json['revoked_at'] == null
      ? null
      : DateTime.parse(json['revoked_at'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  sender: json['sender'] == null
      ? null
      : UserInfo.fromJson(json['sender'] as Map<String, dynamic>),
  attachments: (json['attachments'] as List<dynamic>?)
      ?.map((e) => MessageAttachment.fromJson(e as Map<String, dynamic>))
      .toList(),
  isSelf: json['is_self'] as bool? ?? false,
);

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
  'id': instance.id,
  'conversation_id': instance.conversationId,
  'sender_id': instance.senderId,
  'sender_support_id': instance.senderSupportId,
  'content': instance.content,
  'message_type': instance.messageType,
  'is_revoked': instance.isRevoked,
  'revoked_at': instance.revokedAt?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
  'sender': instance.sender?.toJson(),
  'attachments': instance.attachments?.map((e) => e.toJson()).toList(),
  'is_self': instance.isSelf,
};
