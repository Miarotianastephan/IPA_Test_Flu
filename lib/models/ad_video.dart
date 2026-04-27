import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/utils/json_utils.dart';

part 'ad_video.g.dart';

enum AdTargetType {
  @JsonValue('deeplink')
  deeplink,
  @JsonValue('app')
  app,
}

@JsonSerializable()
class AdVideo {
  @JsonKey(fromJson: parseInt)
  final int id;
  @JsonKey(fromJson: parseInt)
  final int durationConfigId;
  final String? videoUrl;
  @JsonKey(fromJson: parseInt)
  final int duration;
  @JsonKey(fromJson: parseInt)
  final int sortOrder;
  final String? claimUrl;
  final String? jumpUrl;
  final String? title;
  final String? coverImage;
  @JsonKey(fromJson: parseBool)
  final bool? isForce;
  @JsonKey(fromJson: parseBool)
  final bool? isActive;
  @JsonKey(fromJson: parseBool)
  final bool? isSkippable;
  @JsonKey(fromJson: parseInt)
  final int? skipCountdownSeconds;
  @JsonKey(fromJson: parseInt)
  final int? minWatchSeconds;
  @JsonKey(name: 'target_type', unknownEnumValue: AdTargetType.deeplink)
  final AdTargetType? targetType;

  AdVideo({
    required this.id,
    required this.durationConfigId,
    required this.videoUrl,
    required this.duration,
    required this.sortOrder,
    this.claimUrl,
    this.jumpUrl,
    this.title,
    this.coverImage,
    this.isForce,
    this.isActive,
    this.isSkippable,
    this.skipCountdownSeconds,
    this.targetType,
    this.minWatchSeconds,
  });

  factory AdVideo.fromJson(Map<String, dynamic> json) =>
      _$AdVideoFromJson(json);

  Map<String, dynamic> toJson() => _$AdVideoToJson(this);
}
