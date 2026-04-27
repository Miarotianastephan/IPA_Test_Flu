import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/utils/json_utils.dart';

part 'version.g.dart';

@JsonSerializable()
class Version {
  @JsonKey(fromJson: parseInt)
  final int id;

  @JsonKey(name: 'version_number')
  final String versionNumber;

  @JsonKey(name: 'date_release')
  final String? dateRelease;

  final String? description;

  @JsonKey(name: 'url_android')
  final String? urlAndroid;

  @JsonKey(name: 'url_ios')
  final String? urlIos;

  @JsonKey(name: 'force_install', defaultValue: false)
  final bool forceInstall;

  Version({
    required this.id,
    required this.versionNumber,
    this.dateRelease,
    this.description,
    this.urlAndroid,
    this.urlIos,
    this.forceInstall = false,
  });

  factory Version.fromJson(Map<String, dynamic> json) =>
      _$VersionFromJson(json);

  Map<String, dynamic> toJson() => _$VersionToJson(this);
}
