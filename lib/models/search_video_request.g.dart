// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_video_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchVideoRequest _$SearchVideoRequestFromJson(Map<String, dynamic> json) =>
    SearchVideoRequest(
      page: PageParams.fromJson(json['page'] as Map<String, dynamic>),
      keyword: json['keyword'] as String?,
      categoryId: parseInt(json['category_id']),
      tagId: parseInt(json['tag_id']),
      type: (json['type'] as num?)?.toInt(),
      sort: json['sort'] as String?,
      province: json['province'] as String?,
      city: json['city'] as String?,
    );

Map<String, dynamic> _$SearchVideoRequestToJson(SearchVideoRequest instance) {
  final val = <String, dynamic>{
    'page': instance.page,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('keyword', instance.keyword);
  writeNotNull('category_id', instance.categoryId);
  writeNotNull('tag_id', instance.tagId);
  writeNotNull('type', instance.type);
  writeNotNull('sort', instance.sort);
  writeNotNull('province', instance.province);
  writeNotNull('city', instance.city);
  return val;
}
