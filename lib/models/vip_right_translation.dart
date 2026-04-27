import 'package:json_annotation/json_annotation.dart';

part 'vip_right_translation.g.dart';

@JsonSerializable()
class VipRightTranslation {
  @JsonKey(fromJson: _idToString)
  final String id;
  final String lang;
  final String title;
  final String description;

  VipRightTranslation({
    required this.id,
    required this.lang,
    required this.title,
    required this.description,
  });

  static String _idToString(dynamic value) => value?.toString() ?? "";

  factory VipRightTranslation.fromJson(Map<String, dynamic> json) =>
      _$VipRightTranslationFromJson(json);

  Map<String, dynamic> toJson() => _$VipRightTranslationToJson(this);
}
