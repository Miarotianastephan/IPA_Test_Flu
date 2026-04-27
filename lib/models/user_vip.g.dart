// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_vip.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserVip _$UserVipFromJson(Map<String, dynamic> json) => UserVip(
  id: (json['id'] as num).toInt(),
  userId: json['user_id'] as String,
  vipLevelId: (json['vip_level_id'] as num).toInt(),
  vipLevel: VipLevel.fromJson(json['vip_level'] as Map<String, dynamic>),
  status:
      $enumDecodeNullable(_$UserVipStatusEnumMap, json['status']) ??
      UserVipStatus.active,
  startDate: DateTime.parse(json['start_date'] as String),
  endDate: DateTime.parse(json['end_date'] as String),
  orderId: (json['order_id'] as num?)?.toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$UserVipToJson(UserVip instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'vip_level_id': instance.vipLevelId,
  'vip_level': instance.vipLevel.toJson(),
  'status': _$UserVipStatusEnumMap[instance.status]!,
  'start_date': instance.startDate.toIso8601String(),
  'end_date': instance.endDate.toIso8601String(),
  'order_id': instance.orderId,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

const _$UserVipStatusEnumMap = {
  UserVipStatus.active: 'active',
  UserVipStatus.expired: 'expired',
  UserVipStatus.cancelled: 'cancelled',
};
