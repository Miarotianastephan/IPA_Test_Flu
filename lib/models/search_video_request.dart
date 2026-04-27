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

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{...page.toJson()}..remove('type');
    if (keyword?.isNotEmpty ?? false) map['keyword'] = keyword;
    if (categoryId != null) map['category_id'] = categoryId;
    if (tagId != null) map['tag_id'] = tagId;
    if (type != null) map['type'] = type;
    if (sort?.isNotEmpty ?? false) map['sort'] = sort;
    if (province?.isNotEmpty ?? false) map['province'] = province;
    if (city?.isNotEmpty ?? false) map['city'] = city;
    return map;
  }
}
