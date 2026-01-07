// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'i18n_version_check.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

I18nVersionCheck _$I18nVersionCheckFromJson(Map<String, dynamic> json) =>
    I18nVersionCheck(
      hasUpdate: json['has_update'] as bool,
      latestVersion: json['latest_version'] as String,
    );

Map<String, dynamic> _$I18nVersionCheckToJson(I18nVersionCheck instance) =>
    <String, dynamic>{
      'has_update': instance.hasUpdate,
      'latest_version': instance.latestVersion,
    };
