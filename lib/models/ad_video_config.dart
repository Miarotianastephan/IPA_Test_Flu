import 'package:live_app/models/ad_video.dart';
import 'package:live_app/utils/json_utils.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ad_video_config.g.dart';

@JsonSerializable()
class AdVideoConfig {
  @JsonKey(fromJson: parseInt)
  int id;
  @JsonKey(fromJson: parseInt)
  int durationSeconds;
  String? description;
  @JsonKey(fromJson: parseBool)
  bool? isActive;
  @JsonKey(fromJson: parseInt)
  int? sortOrder;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<AdVideo>? adVideos;

  AdVideoConfig({
    required this.id,
    required this.durationSeconds,
    this.description,
    this.isActive,
    this.sortOrder,
    this.createdAt,
    this.updatedAt,
    this.adVideos,
  });

  factory AdVideoConfig.fromJson(Map<String, dynamic> json) => _$AdVideoConfigFromJson(json);
  
  Map<String, dynamic> toJson() => _$AdVideoConfigToJson(this);
  
}
