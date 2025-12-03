// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_inbox.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageInbox _$MessageInboxFromJson(Map<String, dynamic> json) => MessageInbox(
  id: parseInt(json['id']),
  userId: parseInt(json['user_id']),
  messageId: parseInt(json['message_id']),
  conversationId: parseInt(json['conversation_id']),
  isRead: parseBool(json['is_read']),
  isDeleted: parseBool(json['is_deleted']),
  pinned: parseBool(json['pinned']),
  createdAt: json['created_at'] as String,
  message: json['message'] == null
      ? null
      : Message.fromJson(json['message'] as Map<String, dynamic>),
  conversation: json['conversation'] == null
      ? null
      : Conversation.fromJson(json['conversation'] as Map<String, dynamic>),
);

Map<String, dynamic> _$MessageInboxToJson(MessageInbox instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'message_id': instance.messageId,
      'conversation_id': instance.conversationId,
      'is_read': instance.isRead,
      'is_deleted': instance.isDeleted,
      'pinned': instance.pinned,
      'created_at': instance.createdAt,
      'message': instance.message?.toJson(),
      'conversation': instance.conversation?.toJson(),
    };
