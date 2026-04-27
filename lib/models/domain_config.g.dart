// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'domain_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DomainConfig _$DomainConfigFromJson(Map<String, dynamic> json) => DomainConfig(
  version: json['version'] as String,
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  domains: (json['domains'] as List<dynamic>)
      .map((e) => Domain.fromJson(e as Map<String, dynamic>))
      .toList(),
  metadata: DomainMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DomainConfigToJson(DomainConfig instance) =>
    <String, dynamic>{
      'version': instance.version,
      'updatedAt': instance.updatedAt.toIso8601String(),
      'domains': instance.domains,
      'metadata': instance.metadata,
    };

Domain _$DomainFromJson(Map<String, dynamic> json) => Domain(
  id: (json['id'] as num).toInt(),
  domain: json['domain'] as String,
  status: json['status'] as String,
  statusLabel: json['statusLabel'] as String,
  province: json['province'] as String?,
  platform: json['platform'] as String,
  position: (json['position'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  tag: json['tag'] as String,
);

Map<String, dynamic> _$DomainToJson(Domain instance) => <String, dynamic>{
  'id': instance.id,
  'domain': instance.domain,
  'status': instance.status,
  'statusLabel': instance.statusLabel,
  'province': instance.province,
  'platform': instance.platform,
  'position': instance.position,
  'createdAt': instance.createdAt.toIso8601String(),
  'tag': instance.tag,
};

DomainMetadata _$DomainMetadataFromJson(Map<String, dynamic> json) =>
    DomainMetadata(
      totalDomains: (json['totalDomains'] as num).toInt(),
      totalTags: (json['totalTags'] as num).toInt(),
      generatedBy: json['generatedBy'] as String,
    );

Map<String, dynamic> _$DomainMetadataToJson(DomainMetadata instance) =>
    <String, dynamic>{
      'totalDomains': instance.totalDomains,
      'totalTags': instance.totalTags,
      'generatedBy': instance.generatedBy,
    };
