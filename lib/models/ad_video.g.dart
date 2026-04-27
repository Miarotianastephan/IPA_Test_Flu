// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ad_video.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdVideo _$AdVideoFromJson(Map<String, dynamic> json) => AdVideo(
  id: parseInt(json['id']),
  durationConfigId: parseInt(json['durationConfigId']),
  videoUrl: json['videoUrl'] as String?,
  duration: parseInt(json['duration']),
  sortOrder: parseInt(json['sortOrder']),
  claimUrl: json['claimUrl'] as String?,
  jumpUrl: json['jumpUrl'] as String?,
  title: json['title'] as String?,
  coverImage: json['coverImage'] as String?,
  isForce: parseBool(json['isForce']),
  isActive: parseBool(json['isActive']),
  isSkippable: parseBool(json['isSkippable']),
  skipCountdownSeconds: parseInt(json['skipCountdownSeconds']),
  targetType: $enumDecodeNullable(
    _$AdTargetTypeEnumMap,
    json['target_type'],
    unknownValue: AdTargetType.deeplink,
  ),
  minWatchSeconds: parseInt(json['minWatchSeconds']),
);

Map<String, dynamic> _$AdVideoToJson(AdVideo instance) => <String, dynamic>{
  'id': instance.id,
  'durationConfigId': instance.durationConfigId,
  'videoUrl': instance.videoUrl,
  'duration': instance.duration,
  'sortOrder': instance.sortOrder,
  'claimUrl': instance.claimUrl,
  'jumpUrl': instance.jumpUrl,
  'title': instance.title,
  'coverImage': instance.coverImage,
  'isForce': instance.isForce,
  'isActive': instance.isActive,
  'isSkippable': instance.isSkippable,
  'skipCountdownSeconds': instance.skipCountdownSeconds,
  'minWatchSeconds': instance.minWatchSeconds,
  'target_type': _$AdTargetTypeEnumMap[instance.targetType],
};

const _$AdTargetTypeEnumMap = {
  AdTargetType.deeplink: 'deeplink',
  AdTargetType.app: 'app',
};
