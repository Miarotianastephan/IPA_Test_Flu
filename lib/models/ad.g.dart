// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ad.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ad _$AdFromJson(Map<String, dynamic> json) => Ad(
  id: parseInt(json['id']),
  adCode: json['ad_code'] as String,
  adName: json['ad_name'] as String,
  imageSmallUrl: json['image_small_url'] as String?,
  imageMediumUrl: json['image_medium_url'] as String?,
  imageLargeUrl: json['image_large_url'] as String?,
  videoUrl: json['video_url'] as String?,
  videoCoverUrl: json['video_cover_url'] as String?,
  videoDuration: (json['video_duration'] as num?)?.toInt(),
  adTitle: json['ad_title'] as String?,
  adDescription: json['ad_description'] as String?,
  ctaText: json['cta_text'] as String?,
  targetType: $enumDecodeNullable(
    _$AdTargetTypeEnumMap,
    json['target_type'],
    unknownValue: AdTargetType.deeplink,
  ),
  targetUrl: json['target_url'] as String?,
  encryptionKey: json['v_key'] as String? ?? 'fsjkey',
  rewardClaimUrl: json['reward_claim_url'] as String?,
  createdBy: parseIntOrNull(json['created_by']),
  adType: json['ad_type'] as String?,
  sceneCategory: json['scene_category'] as String?,
  isForce: json['is_force'] == null ? false : parseBool(json['is_force']),
  isSkippable: json['is_skippable'] == null
      ? true
      : parseBool(json['is_skippable']),
  skipCountdownSeconds: json['skip_countdown_seconds'] == null
      ? 3
      : parseInt(json['skip_countdown_seconds']),
  closeButtonDelaySeconds: json['close_button_delay_seconds'] == null
      ? 0
      : parseInt(json['close_button_delay_seconds']),
  displayFormat: json['display_format'] as String?,
  priority: json['priority'] == null ? 0 : parseInt(json['priority']),
  weight: json['weight'] == null ? 100 : parseInt(json['weight']),
  startTime: DateTime.parse(json['start_time'] as String),
  endTime: DateTime.parse(json['end_time'] as String),
  status: json['status'] as String? ?? 'draft',
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$AdToJson(Ad instance) => <String, dynamic>{
  'id': instance.id,
  'ad_code': instance.adCode,
  'ad_name': instance.adName,
  'image_small_url': instance.imageSmallUrl,
  'image_medium_url': instance.imageMediumUrl,
  'image_large_url': instance.imageLargeUrl,
  'video_url': instance.videoUrl,
  'v_key': instance.encryptionKey,
  'video_cover_url': instance.videoCoverUrl,
  'video_duration': instance.videoDuration,
  'ad_title': instance.adTitle,
  'ad_description': instance.adDescription,
  'cta_text': instance.ctaText,
  'target_type': _$AdTargetTypeEnumMap[instance.targetType],
  'target_url': instance.targetUrl,
  'reward_claim_url': instance.rewardClaimUrl,
  'created_by': instance.createdBy,
  'ad_type': instance.adType,
  'scene_category': instance.sceneCategory,
  'is_force': instance.isForce,
  'is_skippable': instance.isSkippable,
  'skip_countdown_seconds': instance.skipCountdownSeconds,
  'close_button_delay_seconds': instance.closeButtonDelaySeconds,
  'display_format': instance.displayFormat,
  'priority': instance.priority,
  'weight': instance.weight,
  'start_time': instance.startTime.toIso8601String(),
  'end_time': instance.endTime.toIso8601String(),
  'status': instance.status,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

const _$AdTargetTypeEnumMap = {
  AdTargetType.deeplink: 'deeplink',
  AdTargetType.app: 'app',
};
