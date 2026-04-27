import 'package:json_annotation/json_annotation.dart';

part 'installation_stats.g.dart';

@JsonSerializable()
class InstallationStats {
  final int id;

  @JsonKey(name: 'device_type')
  final String deviceType;

  @JsonKey(name: 'app_version')
  final String? appVersion;

  @JsonKey(name: 'device_fingerprint')
  final String deviceFingerprint;

  @JsonKey(name: 'user_id')
  final String? userId;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @JsonKey(name: 'installation_date')
  final DateTime installationDate;

  const InstallationStats({
    required this.id,
    required this.deviceType,
    this.appVersion,
    required this.deviceFingerprint,
    this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.installationDate,
  });

  factory InstallationStats.fromJson(Map<String, dynamic> json) =>
      _$InstallationStatsFromJson(json);

  Map<String, dynamic> toJson() => _$InstallationStatsToJson(this);
}
