import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/utils/json_utils.dart';

part 'forum_category.g.dart';

@JsonSerializable(explicitToJson: true)
class ForumCategory {
  @JsonKey(fromJson: parseInt)
  final int id;
  final String name;
  final String? description;
  @JsonKey(name: 'parent_id', fromJson: parseInt)
  final int? parentId;
  final int? sort;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  @JsonKey(name: 'deleted_at')
  final String? deletedAt;
  final List<ForumCategory>? children;

  ForumCategory({
    required this.id,
    required this.name,
    this.description,
    this.parentId,
    this.sort,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.children,
  });

  factory ForumCategory.fromJson(Map<String, dynamic> json) =>
      _$ForumCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$ForumCategoryToJson(this);
}
