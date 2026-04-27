// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_support.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AgentSupport _$AgentSupportFromJson(Map<String, dynamic> json) => AgentSupport(
  id: json['id'] as String,
  username: json['username'] as String?,
  loginId: json['loginId'] as String?,
  password: json['password'] as String?,
  passwordRetrait: json['password_retrait'] as String?,
  role: json['role'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
  code: json['code'] as String?,
  parentId: json['parent_id'] as String?,
  isActive: json['is_active'] == null ? false : parseBool(json['is_active']),
  revenue: json['revenue'] == null ? 0.0 : parseDouble(json['revenue']),
  commissionRate: json['commission_rate'] == null
      ? 0
      : parseInt(json['commission_rate']),
  estimatedRevenue: json['estimated_revenue'] == null
      ? 0.0
      : parseDouble(json['estimated_revenue']),
  withdrawableAmount: json['withdrawable_amount'] == null
      ? 0.0
      : parseDouble(json['withdrawable_amount']),
  withdrawingAmount: json['withdrawing_amount'] == null
      ? 0.0
      : parseDouble(json['withdrawing_amount']),
  withdrawnAmount: json['withdrawn_amount'] == null
      ? 0.0
      : parseDouble(json['withdrawn_amount']),
  avatar: json['avatar'] as String?,
);

Map<String, dynamic> _$AgentSupportToJson(AgentSupport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'loginId': instance.loginId,
      'password': instance.password,
      'password_retrait': instance.passwordRetrait,
      'role': instance.role,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'code': instance.code,
      'parent_id': instance.parentId,
      'is_active': instance.isActive,
      'revenue': instance.revenue,
      'commission_rate': instance.commissionRate,
      'estimated_revenue': instance.estimatedRevenue,
      'withdrawable_amount': instance.withdrawableAmount,
      'withdrawing_amount': instance.withdrawingAmount,
      'withdrawn_amount': instance.withdrawnAmount,
      'avatar': instance.avatar,
    };
