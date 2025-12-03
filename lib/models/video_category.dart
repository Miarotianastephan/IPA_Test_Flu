import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/utils/json_utils.dart';

part 'video_category.g.dart';

@JsonSerializable()
class VideoCategory {
   @JsonKey(fromJson: parseInt)
  final int id;
  final String name;
  final int type;
  final int sort;
  @JsonKey(name: 'is_home')
  final int isHome;

  VideoCategory({
    required this.id,
    required this.name,
    required this.type,
    required this.sort,
    required this.isHome,
  });

  factory VideoCategory.fromJson(Map<String, dynamic> json) =>
      _$VideoCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$VideoCategoryToJson(this);
}
