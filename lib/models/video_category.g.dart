// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoCategory _$VideoCategoryFromJson(Map<String, dynamic> json) =>
    VideoCategory(
      id: parseInt(json['id']),
      name: json['name'] as String,
      type: (json['type'] as num).toInt(),
      sort: (json['sort'] as num).toInt(),
      isHome: (json['is_home'] as num).toInt(),
    );

Map<String, dynamic> _$VideoCategoryToJson(VideoCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'sort': instance.sort,
      'is_home': instance.isHome,
    };
