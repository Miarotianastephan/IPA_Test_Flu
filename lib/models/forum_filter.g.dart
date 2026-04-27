// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forum_filter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ForumFilter _$ForumFilterFromJson(Map<String, dynamic> json) => ForumFilter(
  recent: json['recent'] as bool? ?? false,
  selection: json['selection'] as bool? ?? false,
  video: json['video'] as bool? ?? false,
);

Map<String, dynamic> _$ForumFilterToJson(ForumFilter instance) =>
    <String, dynamic>{
      'recent': instance.recent,
      'selection': instance.selection,
      'video': instance.video,
    };
