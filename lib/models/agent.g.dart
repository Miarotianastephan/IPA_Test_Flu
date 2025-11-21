// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Agent _$AgentFromJson(Map<String, dynamic> json) => Agent(
  id: parseInt(json['id']),
  displayId: parseInt(json['display_id']),
  username: json['username'] as String?,
  role: json['role'] as String?,
  code: json['code'] as String?,
  parentId: parseInt(json['parent_id']),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$AgentToJson(Agent instance) => <String, dynamic>{
  'id': instance.id,
  'display_id': instance.displayId,
  'username': instance.username,
  'role': instance.role,
  'code': instance.code,
  'parent_id': instance.parentId,
  'created_at': instance.createdAt?.toIso8601String(),
};
