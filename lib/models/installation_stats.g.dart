// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'installation_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InstallationStats _$InstallationStatsFromJson(Map<String, dynamic> json) =>
    InstallationStats(
      id: (json['id'] as num).toInt(),
      deviceType: json['device_type'] as String,
      appVersion: json['app_version'] as String?,
      deviceFingerprint: json['device_fingerprint'] as String,
      userId: json['user_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      installationDate: DateTime.parse(json['installation_date'] as String),
    );

Map<String, dynamic> _$InstallationStatsToJson(InstallationStats instance) =>
    <String, dynamic>{
      'id': instance.id,
      'device_type': instance.deviceType,
      'app_version': instance.appVersion,
      'device_fingerprint': instance.deviceFingerprint,
      'user_id': instance.userId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'installation_date': instance.installationDate.toIso8601String(),
    };
