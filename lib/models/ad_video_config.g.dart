// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ad_video_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdVideoConfig _$AdVideoConfigFromJson(Map<String, dynamic> json) =>
    AdVideoConfig(
      id: parseInt(json['id']),
      durationSeconds: parseInt(json['durationSeconds']),
      description: json['description'] as String?,
      isActive: parseBool(json['isActive']),
      sortOrder: parseInt(json['sortOrder']),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      adVideos: (json['adVideos'] as List<dynamic>?)
          ?.map((e) => AdVideo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AdVideoConfigToJson(AdVideoConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'durationSeconds': instance.durationSeconds,
      'description': instance.description,
      'isActive': instance.isActive,
      'sortOrder': instance.sortOrder,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'adVideos': instance.adVideos,
    };
