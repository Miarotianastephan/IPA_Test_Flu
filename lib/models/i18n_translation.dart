import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/utils/json_utils.dart';

part 'i18n_translation.g.dart';

@JsonSerializable(explicitToJson: true)
class I18nTranslation {
  @JsonKey(fromJson: parseInt)
  final int id;

  final String key;
  @JsonKey(name: 'translation_value')
  final String translationValue;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  I18nTranslation({
    required this.id,
    required this.key,
    required this.translationValue,
    required this.createdAt,
    required this.updatedAt,
  });

  factory I18nTranslation.fromJson(Map<String, dynamic> json) =>
      _$I18nTranslationFromJson(json);

  Map<String, dynamic> toJson() => _$I18nTranslationToJson(this);

  I18nTranslation copyWith({
    int? id,
    int? countryLanguageId,
    String? key,
    String? translationValue,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return I18nTranslation(
      id: id ?? this.id,
      key: key ?? this.key,
      translationValue: translationValue ?? this.translationValue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'I18nTranslation(id: $id, key: $key, translationValue: $translationValue)';
}
