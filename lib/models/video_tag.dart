import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/utils/json_utils.dart';

part 'video_tag.g.dart';

@JsonSerializable()
class VideoTag {
  @JsonKey(fromJson: parseInt)
  final int id;
  final String name;
  @JsonKey(name: 'created_at')
  final String createdAt;

  VideoTag({required this.id, required this.name, required this.createdAt});

  factory VideoTag.fromJson(Map<String, dynamic> json) =>
      _$VideoTagFromJson(json);

  Map<String, dynamic> toJson() => _$VideoTagToJson(this);
}
