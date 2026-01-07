import 'package:json_annotation/json_annotation.dart';

part 'i18n_version_check.g.dart';

@JsonSerializable(explicitToJson: true)
class I18nVersionCheck {
  @JsonKey(name: 'has_update')
  final bool hasUpdate;

  @JsonKey(name: 'latest_version')
  final String latestVersion;

  I18nVersionCheck({required this.hasUpdate, required this.latestVersion});

  factory I18nVersionCheck.fromJson(Map<String, dynamic> json) =>
      _$I18nVersionCheckFromJson(json);

  Map<String, dynamic> toJson() => _$I18nVersionCheckToJson(this);

  I18nVersionCheck copyWith({bool? hasUpdate, String? latestVersion}) {
    return I18nVersionCheck(
      hasUpdate: hasUpdate ?? this.hasUpdate,
      latestVersion: latestVersion ?? this.latestVersion,
    );
  }

  @override
  String toString() =>
      'I18nVersionCheck(hasUpdate: $hasUpdate, latestVersion: $latestVersion)';
}
