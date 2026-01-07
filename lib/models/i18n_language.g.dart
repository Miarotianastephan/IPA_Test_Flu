// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'i18n_language.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

I18nLanguage _$I18nLanguageFromJson(Map<String, dynamic> json) => I18nLanguage(
  id: parseInt(json['id']),
  countryName: json['country_name'] as String,
  languageCode: json['language_code'] as String,
  flagUrl: json['flag_url'] as String,
  version: json['version'] as String,
  isDelete: (json['is_delete'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$I18nLanguageToJson(I18nLanguage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'country_name': instance.countryName,
      'language_code': instance.languageCode,
      'flag_url': instance.flagUrl,
      'version': instance.version,
      'is_delete': instance.isDelete,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
