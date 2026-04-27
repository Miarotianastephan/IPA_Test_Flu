// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'version.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Version _$VersionFromJson(Map<String, dynamic> json) => Version(
  id: parseInt(json['id']),
  versionNumber: json['version_number'] as String,
  dateRelease: json['date_release'] as String?,
  description: json['description'] as String?,
  urlAndroid: json['url_android'] as String?,
  urlIos: json['url_ios'] as String?,
  forceInstall: json['force_install'] as bool? ?? false,
);

Map<String, dynamic> _$VersionToJson(Version instance) => <String, dynamic>{
  'id': instance.id,
  'version_number': instance.versionNumber,
  'date_release': instance.dateRelease,
  'description': instance.description,
  'url_android': instance.urlAndroid,
  'url_ios': instance.urlIos,
  'force_install': instance.forceInstall,
};
