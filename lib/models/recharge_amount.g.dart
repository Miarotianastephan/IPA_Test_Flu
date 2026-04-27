// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recharge_amount.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RechargeAmount _$RechargeAmountFromJson(Map<String, dynamic> json) =>
    RechargeAmount(
      id: parseInt(json['id']),
      amount: parseDouble(json['amount']),
      currency: json['currency'] as String,
      bonusAmount: json['bonus_amount'] == null
          ? 0.0
          : parseDouble(json['bonus_amount']),
      isPopular: json['is_popular'] == null
          ? false
          : parseBool(json['is_popular']),
      label: json['label'] as String?,
      sortOrder: json['sort_order'] == null ? 0 : parseInt(json['sort_order']),
      agentId: parseInt(json['agent_id']),
      isActive: json['is_active'] == null ? true : parseBool(json['is_active']),
    );

Map<String, dynamic> _$RechargeAmountToJson(RechargeAmount instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'currency': instance.currency,
      'bonus_amount': instance.bonusAmount,
      'is_popular': instance.isPopular,
      'label': instance.label,
      'sort_order': instance.sortOrder,
      'agent_id': instance.agentId,
      'is_active': instance.isActive,
    };
