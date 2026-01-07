// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Group _$GroupFromJson(Map<String, dynamic> json) => Group(
  id: parseInt(json['id']),
  name: json['name'] as String,
  description: json['description'] as String?,
  avatarUrl: json['avatar_url'] as String?,
  visibility: json['visibility'] as String,
  ownerId: json['owner_id'] as String,
  conversationId: parseInt(json['conversation_id']),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$GroupToJson(Group instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'avatar_url': instance.avatarUrl,
  'visibility': instance.visibility,
  'owner_id': instance.ownerId,
  'conversation_id': instance.conversationId,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
