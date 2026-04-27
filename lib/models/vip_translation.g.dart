// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vip_translation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VipTranslation _$VipTranslationFromJson(Map<String, dynamic> json) =>
    VipTranslation(
      id: parseInt(json['id']),
      lang: json['lang'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      shortIntro: json['short_intro'] as String?,
    );

Map<String, dynamic> _$VipTranslationToJson(VipTranslation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'lang': instance.lang,
      'name': instance.name,
      'description': instance.description,
      'short_intro': instance.shortIntro,
    };
