// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vip_level.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VipLevel _$VipLevelFromJson(Map<String, dynamic> json) => VipLevel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  durationDays: parseInt(json['duration_days']),
  price: parseDouble(json['price']),
  discountRate: parseDouble(json['discount_rate']),
  benefits: (json['benefits'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  displayOrder: json['display_order'] == null
      ? 0
      : parseInt(json['display_order']),
  isActive: json['is_active'] == null ? true : parseBool(json['is_active']),
  badgeIcon: json['badge_icon'] as String?,
  backgroundColor: json['background_color'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$VipLevelToJson(VipLevel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'duration_days': instance.durationDays,
  'price': instance.price,
  'discount_rate': instance.discountRate,
  'benefits': instance.benefits,
  'display_order': instance.displayOrder,
  'is_active': instance.isActive,
  'badge_icon': instance.badgeIcon,
  'background_color': instance.backgroundColor,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
