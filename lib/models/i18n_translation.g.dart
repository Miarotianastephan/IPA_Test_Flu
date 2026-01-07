// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'i18n_translation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

I18nTranslation _$I18nTranslationFromJson(Map<String, dynamic> json) =>
    I18nTranslation(
      id: parseInt(json['id']),
      key: json['key'] as String,
      translationValue: json['translation_value'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$I18nTranslationToJson(I18nTranslation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'key': instance.key,
      'translation_value': instance.translationValue,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
