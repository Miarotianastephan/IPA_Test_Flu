// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forum_tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ForumTag _$ForumTagFromJson(Map<String, dynamic> json) => ForumTag(
  id: parseInt(json['id']),
  name: json['name'] as String,
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$ForumTagToJson(ForumTag instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'created_at': instance.createdAt,
};
