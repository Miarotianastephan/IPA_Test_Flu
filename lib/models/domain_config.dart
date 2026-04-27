import 'package:json_annotation/json_annotation.dart';

part 'domain_config.g.dart';

@JsonSerializable()
class DomainConfig {
  final String version;
  final DateTime updatedAt;
  final List<Domain> domains;
  final DomainMetadata metadata;

  DomainConfig({
    required this.version,
    required this.updatedAt,
    required this.domains,
    required this.metadata,
  });

  factory DomainConfig.fromJson(Map<String, dynamic> json) =>
      _$DomainConfigFromJson(json);

  Map<String, dynamic> toJson() => _$DomainConfigToJson(this);

  @override
  String toString() {
    return 'DomainConfig(version: $version, updatedAt: $updatedAt, domains: ${domains.length}, metadata: $metadata)';
  }
}

@JsonSerializable()
class Domain {
  final int id;
  final String domain;
  final String status;
  final String statusLabel;
  final String? province;
  final String platform;
  final int position;
  final DateTime createdAt;
  final String tag;

  Domain({
    required this.id,
    required this.domain,
    required this.status,
    required this.statusLabel,
    this.province,
    required this.platform,
    required this.position,
    required this.createdAt,
    required this.tag,
  });

  factory Domain.fromJson(Map<String, dynamic> json) => _$DomainFromJson(json);

  Map<String, dynamic> toJson() => _$DomainToJson(this);

  @override
  String toString() {
    return 'Domain(id: $id, domain: $domain, status: $status, statusLabel: $statusLabel, province: $province, platform: $platform, position: $position, createdAt: $createdAt, tag: $tag)';
  }
}

@JsonSerializable()
class DomainMetadata {
  final int totalDomains;
  final int totalTags;
  final String generatedBy;

  DomainMetadata({
    required this.totalDomains,
    required this.totalTags,
    required this.generatedBy,
  });

  factory DomainMetadata.fromJson(Map<String, dynamic> json) =>
      _$DomainMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$DomainMetadataToJson(this);
}
