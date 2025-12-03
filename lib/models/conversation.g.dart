// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Conversation _$ConversationFromJson(Map<String, dynamic> json) => Conversation(
  id: parseInt(json['id']),
  name: json['name'] as String?,
  type: json['type'] as String,
  lastMessageId: parseInt(json['last_message_id']),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
  users:
      (json['users'] as List<dynamic>?)
          ?.map((e) => ConversationUser.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  lastMessage: json['last_message'] == null
      ? null
      : Message.fromJson(json['last_message'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ConversationToJson(Conversation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'last_message_id': instance.lastMessageId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'unread_count': instance.unreadCount,
      'users': instance.users.map((e) => e.toJson()).toList(),
      'last_message': instance.lastMessage?.toJson(),
    };
