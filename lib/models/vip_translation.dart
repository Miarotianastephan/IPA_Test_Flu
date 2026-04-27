import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/utils/json_utils.dart';

part 'vip_translation.g.dart';

@JsonSerializable()
class VipTranslation {
  @JsonKey(fromJson: parseInt)
  final int id;
  final String lang;
  final String name;
  final String description;

  @JsonKey(name: 'short_intro')
  final String? shortIntro;

  VipTranslation({
    required this.id,
    required this.lang,
    required this.name,
    required this.description,
    this.shortIntro,
  });

  factory VipTranslation.empty() => VipTranslation(
        id: 0,
        lang: '',
        name: '',
        description: '',
      );

  factory VipTranslation.fromJson(Map<String, dynamic> json) =>
      _$VipTranslationFromJson(json);

  Map<String, dynamic> toJson() => _$VipTranslationToJson(this);
}
