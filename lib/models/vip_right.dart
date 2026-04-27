import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/models/vip_right_translation.dart';

part 'vip_right.g.dart';

@JsonSerializable(explicitToJson: true)
class VipRight {
  @JsonKey(fromJson: _idToString)
  final String id;
  final String code;

  static String _idToString(dynamic value) => value?.toString() ?? "";

  @JsonKey(name: 'logo_url')
  final String? logoUrl;

  @JsonKey(name: 'display_order')
  final int displayOrder;

  @JsonKey(name: 'is_enabled')
  final bool isEnabled;

  final VipRightTranslation translations;

  VipRight({
    required this.id,
    required this.code,
    this.logoUrl,
    required this.displayOrder,
    required this.isEnabled,
    required this.translations,
  });

  factory VipRight.fromJson(Map<String, dynamic> json) =>
      _$VipRightFromJson(json);

  Map<String, dynamic> toJson() => _$VipRightToJson(this);
}
