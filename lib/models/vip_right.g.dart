// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vip_right.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VipRight _$VipRightFromJson(Map<String, dynamic> json) => VipRight(
  id: VipRight._idToString(json['id']),
  code: json['code'] as String,
  logoUrl: json['logo_url'] as String?,
  displayOrder: (json['display_order'] as num).toInt(),
  isEnabled: json['is_enabled'] as bool,
  translations: VipRightTranslation.fromJson(
    json['translations'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$VipRightToJson(VipRight instance) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'logo_url': instance.logoUrl,
  'display_order': instance.displayOrder,
  'is_enabled': instance.isEnabled,
  'translations': instance.translations.toJson(),
};
