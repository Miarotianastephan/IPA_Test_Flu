// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_package.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimePackage _$TimePackageFromJson(Map<String, dynamic> json) => TimePackage(
  id: parseInt(json['id']),
  durationSeconds: parseInt(json['duration_seconds']),
  price: parseDouble(json['price']),
  currency: json['currency'] as String,
  isDailyPass: json['is_daily_pass'] == null
      ? false
      : parseBool(json['is_daily_pass']),
  isPopular: json['is_popular'] == null ? false : parseBool(json['is_popular']),
  label: json['label'] as String?,
  sortOrder: json['sort_order'] == null ? 0 : parseInt(json['sort_order']),
  agentId: parseInt(json['agent_id']),
  isActive: json['is_active'] == null ? true : parseBool(json['is_active']),
);

Map<String, dynamic> _$TimePackageToJson(TimePackage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'duration_seconds': instance.durationSeconds,
      'price': instance.price,
      'currency': instance.currency,
      'is_daily_pass': instance.isDailyPass,
      'is_popular': instance.isPopular,
      'label': instance.label,
      'sort_order': instance.sortOrder,
      'agent_id': instance.agentId,
      'is_active': instance.isActive,
    };
