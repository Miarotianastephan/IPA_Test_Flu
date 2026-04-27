import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/models/vip_translation.dart';
import 'package:live_app/models/vip_right.dart';
import 'package:live_app/utils/json_utils.dart';

part 'vip.g.dart';

@JsonSerializable(explicitToJson: true)
class Vip {
  @JsonKey(fromJson: _idToString)
  final String id;

  static String _idToString(dynamic value) => value?.toString() ?? "";

  @JsonKey(name: 'valid_days', fromJson: parseInt)
  final int validDays;

  @JsonKey(name: 'base_price', defaultValue: '0')
  final String basePrice;

  @JsonKey(name: 'is_active', fromJson: parseBool)
  final bool isActive;

  @JsonKey(name: 'logo_url', defaultValue: '')
  final String logoUrl;

  @JsonKey(name: 'display_order', fromJson: parseInt)
  final int displayOrder;

  @JsonKey(name: 'is_recommended', fromJson: parseBool)
  final bool isRecommended;

  @JsonKey(name: 'translations')
  final VipTranslation? _translations;

  /// Safe getter that returns empty translation if null
  VipTranslation get translations => _translations ?? VipTranslation.empty();

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(defaultValue: [])
  final List<VipRight> rights;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  Vip({
    required this.id,
    required this.validDays,
    required this.basePrice,
    required this.isActive,
    required this.logoUrl,
    required this.displayOrder,
    required this.isRecommended,
    VipTranslation? translations,
    required this.rights,
    this.createdAt,
    this.updatedAt,
  }) : _translations = translations;

  factory Vip.fromJson(Map<String, dynamic> json) => _$VipFromJson(json);

  Map<String, dynamic> toJson() => _$VipToJson(this);
}
