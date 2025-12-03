// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_params.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PageParams _$PageParamsFromJson(Map<String, dynamic> json) => PageParams(
  page: (json['page'] as num?)?.toInt() ?? 1,
  limit: (json['limit'] as num?)?.toInt() ?? 20,
  type: (json['type'] as num?)?.toInt() ?? 2,
);

Map<String, dynamic> _$PageParamsToJson(PageParams instance) =>
    <String, dynamic>{
      'page': instance.page,
      'limit': instance.limit,
      'type': instance.type,
    };
