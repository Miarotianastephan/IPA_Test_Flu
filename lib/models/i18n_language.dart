import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/utils/json_utils.dart';

part 'i18n_language.g.dart';

@JsonSerializable(explicitToJson: true)
class I18nLanguage {
  @JsonKey(fromJson: parseInt)
  final int id;

  @JsonKey(name: 'country_name')
  final String countryName;

  @JsonKey(name: 'language_code')
  final String languageCode;

  @JsonKey(name: 'flag_url')
  final String flagUrl;

  final String version;

  @JsonKey(name: 'is_delete')
  final int isDelete;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  String get displayName => countryName;

  I18nLanguage({
    required this.id,
    required this.countryName,
    required this.languageCode,
    required this.flagUrl,
    required this.version,
    required this.isDelete,
    required this.createdAt,
    required this.updatedAt,
  });

  factory I18nLanguage.fromJson(Map<String, dynamic> json) =>
      _$I18nLanguageFromJson(json);

  Map<String, dynamic> toJson() => _$I18nLanguageToJson(this);

  I18nLanguage copyWith({
    int? id,
    String? countryName,
    String? languageCode,
    String? flagUrl,
    String? version,
    int? isDelete,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return I18nLanguage(
      id: id ?? this.id,
      countryName: countryName ?? this.countryName,
      languageCode: languageCode ?? this.languageCode,
      flagUrl: flagUrl ?? this.flagUrl,
      version: version ?? this.version,
      isDelete: isDelete ?? this.isDelete,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'I18nLanguage(id: $id, countryName: $countryName, languageCode: $languageCode, flagUrl: $flagUrl, version: $version)';
  }
}
