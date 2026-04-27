// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vip_right_translation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VipRightTranslation _$VipRightTranslationFromJson(Map<String, dynamic> json) =>
    VipRightTranslation(
      id: VipRightTranslation._idToString(json['id']),
      lang: json['lang'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
    );

Map<String, dynamic> _$VipRightTranslationToJson(
  VipRightTranslation instance,
) => <String, dynamic>{
  'id': instance.id,
  'lang': instance.lang,
  'title': instance.title,
  'description': instance.description,
};
