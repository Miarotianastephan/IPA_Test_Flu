import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/utils/json_utils.dart';
import 'page_params.dart';

part 'search_video_request.g.dart';

@JsonSerializable(includeIfNull: false)
class SearchVideoRequest {
  final PageParams page;
  final String? keyword;
  @JsonKey(name: 'category_id', fromJson: parseInt)
  final int? categoryId;
  @JsonKey(name: 'tag_id', fromJson: parseInt)
  final int? tagId;
  final int? type;
  final String? sort;
  final String? province;
  final String? city;

  SearchVideoRequest({
    required this.page,
    this.keyword,
    this.categoryId,
    this.tagId,
    this.type,
    this.sort,
    this.province,
    this.city,
  });

  factory SearchVideoRequest.fromJson(Map<String, dynamic> json) =>
      _$SearchVideoRequestFromJson(json);

  Map<String, dynamic> toJson() => {
    ...page.toJson(),
    if (keyword?.isNotEmpty ?? false) 'keyword': keyword,
    if (categoryId != null) 'category_id': categoryId,
    if (tagId != null) 'tag_id': tagId,
    if (type != null) 'type': type,
    if (sort?.isNotEmpty ?? false) 'sort': sort,
    if (province?.isNotEmpty ?? false) 'province': province,
    if (city?.isNotEmpty ?? false) 'city': city,
  };
}