import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/utils/json_utils.dart';

part 'forum_tag.g.dart';

@JsonSerializable()
class ForumTag {
  @JsonKey(fromJson: parseInt)
  final int id;
  final String name;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  ForumTag({required this.id, required this.name, this.createdAt});

  factory ForumTag.fromJson(Map<String, dynamic> json) =>
      _$ForumTagFromJson(json);

  Map<String, dynamic> toJson() => _$ForumTagToJson(this);
}
