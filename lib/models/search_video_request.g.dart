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

Map<String, dynamic> _$SearchVideoRequestToJson(SearchVideoRequest instance) =>
    <String, dynamic>{
      'page': instance.page,
      'keyword': ?instance.keyword,
      'category_id': ?instance.categoryId,
      'tag_id': ?instance.tagId,
      'type': ?instance.type,
      'sort': ?instance.sort,
      'province': ?instance.province,
      'city': ?instance.city,
    };
