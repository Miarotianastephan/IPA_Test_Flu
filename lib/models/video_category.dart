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


// class VideoCategory {
//   final int id;
//   final String name;
//   final int type;
//   final int sort;
//   final int isHome;
//
//   VideoCategory({
//     required this.id,
//     required this.name,
//     required this.type,
//     required this.sort,
//     required this.isHome,
//   });
//
//   factory VideoCategory.fromJson(Map<String, dynamic> json) {
//     return VideoCategory(
//       id: json['id'] as int,
//       name: json['name'] as String,
//       type: json['type'] as int,
//       sort: json['sort'] as int,
//       isHome: json['is_home'] as int,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'type': type,
//       'sort': sort,
//       'is_home': isHome,
//     };
//   }
// }
