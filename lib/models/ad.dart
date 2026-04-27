import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/utils/json_utils.dart';

part 'ad.g.dart';

enum AdTargetType {
  @JsonValue('deeplink')
  deeplink,
  @JsonValue('app')
  app,
}

@JsonSerializable()
class Ad {
  @JsonKey(fromJson: parseInt)
  final int id;

  @JsonKey(name: 'ad_code')
  final String adCode;

  @JsonKey(name: 'ad_name')
  final String adName;

  @JsonKey(name: 'image_small_url')
  final String? imageSmallUrl;

  @JsonKey(name: 'image_medium_url')
  final String? imageMediumUrl;

  @JsonKey(name: 'image_large_url')
  final String? imageLargeUrl;

  @JsonKey(name: 'video_url')
  final String? videoUrl;

  @JsonKey(name: 'v_key', defaultValue: 'fsjkey')
  final String encryptionKey;

  @JsonKey(name: 'video_cover_url')
  final String? videoCoverUrl;

  @JsonKey(name: 'video_duration')
  final int? videoDuration;

  @JsonKey(name: 'ad_title')
  final String? adTitle;

  @JsonKey(name: 'ad_description')
  final String? adDescription;

  @JsonKey(name: 'cta_text')
  final String? ctaText;

  @JsonKey(name: 'target_type', unknownEnumValue: AdTargetType.deeplink)
  final AdTargetType? targetType;

  @JsonKey(name: 'target_url')
  final String? targetUrl;

  @JsonKey(name: 'reward_claim_url')
  final String? rewardClaimUrl;

  @JsonKey(name: 'created_by', fromJson: parseIntOrNull)
  final int? createdBy;

  @JsonKey(name: 'ad_type')
  final String? adType;

  @JsonKey(name: 'scene_category')
  final String? sceneCategory;

  @JsonKey(name: 'is_force', fromJson: parseBool)
  final bool isForce;

  @JsonKey(name: 'is_skippable', fromJson: parseBool)
  final bool isSkippable;

  @JsonKey(name: 'skip_countdown_seconds', fromJson: parseInt)
  final int skipCountdownSeconds;

  @JsonKey(name: 'close_button_delay_seconds', fromJson: parseInt)
  final int closeButtonDelaySeconds;

  @JsonKey(name: 'display_format')
  final String? displayFormat;

  @JsonKey(fromJson: parseInt)
  final int priority;
  @JsonKey(fromJson: parseInt)
  final int weight;

  @JsonKey(name: 'start_time')
  final DateTime startTime;

  @JsonKey(name: 'end_time')
  final DateTime endTime;

  final String status;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @JsonKey(includeFromJson: false, includeToJson: false)
  String? ruleCode;

  Ad({
    required this.id,
    required this.adCode,
    required this.adName,
    this.imageSmallUrl,
    this.imageMediumUrl,
    this.imageLargeUrl,
    this.videoUrl,
    this.videoCoverUrl,
    this.videoDuration,
    this.adTitle,
    this.adDescription,
    this.ctaText,
    this.targetType,
    this.targetUrl,
    this.encryptionKey = 'fsjkey',
    this.rewardClaimUrl,
    this.createdBy,
    this.adType,
    this.sceneCategory,
    this.isForce = false,
    this.isSkippable = true,
    this.skipCountdownSeconds = 3,
    this.closeButtonDelaySeconds = 0,
    this.displayFormat,
    this.priority = 0,
    this.weight = 100,
    required this.startTime,
    required this.endTime,
    this.status = 'draft',
    required this.createdAt,
    required this.updatedAt,
    this.ruleCode,
  });

  factory Ad.fromJson(Map<String, dynamic> json) => _$AdFromJson(json);

  Map<String, dynamic> toJson() => _$AdToJson(this);
}
