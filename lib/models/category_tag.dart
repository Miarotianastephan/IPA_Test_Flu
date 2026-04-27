import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/utils/json_utils.dart';
part 'category_tag.g.dart';

@JsonSerializable()
class CategoryTag {
  @JsonKey(fromJson: parseInt)
  final int id;
  final String name;
  CategoryTag({required this.id, required this.name});
  factory CategoryTag.fromJson(Map<String, dynamic> json) =>
      _$CategoryTagFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryTagToJson(this);
}
