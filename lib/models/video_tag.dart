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


// class VideoTag {
//   final int id;
//   final String name;
//   final String createdAt;
//   // final String updatedAt;
//   // final String? deletedAt;
//
//   VideoTag({
//     required this.id,
//     required this.name,
//     required this.createdAt,
//     // required this.updatedAt,
//     // this.deletedAt,
//   });
//
//   factory VideoTag.fromJson(Map<String, dynamic> json) {
//     return VideoTag(
//       id: json['id'] as int,
//       name: json['name'] as String,
//       createdAt: json['created_at'] as String,
//       // updatedAt: json['updated_at'] as String,
//       // deletedAt: json['deleted_at'] as String?,
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'name': name,
//     'created_at': createdAt,
//     // 'updated_at': updatedAt,
//     // 'deleted_at': deletedAt,
//   };
// }