// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoTag _$VideoTagFromJson(Map<String, dynamic> json) => VideoTag(
  id: parseInt(json['id']),
  name: json['name'] as String,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$VideoTagToJson(VideoTag instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'created_at': instance.createdAt,
};
