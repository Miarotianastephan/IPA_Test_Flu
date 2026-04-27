import 'package:json_annotation/json_annotation.dart';

part 'forum_filter.g.dart';

@JsonSerializable()
class ForumFilter {
  @JsonKey(defaultValue: false)
  final bool? recent;
  @JsonKey(defaultValue: false)
  final bool? selection;
  @JsonKey(defaultValue: false)
  final bool? video;

  ForumFilter({this.recent, this.selection, this.video});

  factory ForumFilter.fromJson(Map<String, dynamic> json) =>
      _$ForumFilterFromJson(json);

  Map<String, dynamic> toJson() => _$ForumFilterToJson(this);
}
