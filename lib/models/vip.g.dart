// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vip.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Vip _$VipFromJson(Map<String, dynamic> json) => Vip(
  id: Vip._idToString(json['id']),
  validDays: parseInt(json['valid_days']),
  basePrice: json['base_price'] as String? ?? '0',
  isActive: parseBool(json['is_active']),
  logoUrl: json['logo_url'] as String? ?? '',
  displayOrder: parseInt(json['display_order']),
  isRecommended: parseBool(json['is_recommended']),
  translations: json['translations'] == null
      ? null
      : VipTranslation.fromJson(json['translations'] as Map<String, dynamic>),
  rights:
      (json['rights'] as List<dynamic>?)
          ?.map((e) => VipRight.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$VipToJson(Vip instance) => <String, dynamic>{
  'id': instance.id,
  'valid_days': instance.validDays,
  'base_price': instance.basePrice,
  'is_active': instance.isActive,
  'logo_url': instance.logoUrl,
  'display_order': instance.displayOrder,
  'is_recommended': instance.isRecommended,
  'translations': instance.translations.toJson(),
  'created_at': instance.createdAt?.toIso8601String(),
  'rights': instance.rights.map((e) => e.toJson()).toList(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
