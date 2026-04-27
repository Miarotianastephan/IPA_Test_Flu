// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentOrder _$PaymentOrderFromJson(Map<String, dynamic> json) => PaymentOrder(
  id: json['id'] as String,
  orderNo: json['orderNo'] as String,
  userId: json['userId'] as String,
  agentId: json['agentId'] as String?,
  bizType: $enumDecode(_$BizTypeEnumMap, json['bizType']),
  bizId: json['bizId'] as String?,
  currency: json['currency'] as String? ?? 'CNY',
  amount: parseDouble(json['amount']),
  basePriceCny: parseDouble(json['basePriceCny']),
  originalCurrency: json['originalCurrency'] as String?,
  originalAmount: parseDoubleOrNull(json['originalAmount']),
  exchangeRate: parseDoubleOrNull(json['exchangeRate']),
  paymentPlatformId: parseInt(json['paymentPlatformId']),
  paymentChannelId: parseIntOrNull(json['paymentChannelId']),
  paymentPlatformOrderNo: json['paymentPlatformOrderNo'] as String?,
  paymentMethod: json['paymentMethod'] as String?,
  status:
      $enumDecodeNullable(_$PaymentOrderStatusEnumMap, json['status']) ??
      PaymentOrderStatus.pending,
  createdAt: DateTime.parse(json['createdAt'] as String),
  paidAt: json['paidAt'] == null
      ? null
      : DateTime.parse(json['paidAt'] as String),
  expiredAt: json['expiredAt'] == null
      ? null
      : DateTime.parse(json['expiredAt'] as String),
  notifyCount: (json['notifyCount'] as num?)?.toInt() ?? 0,
  lastNotifyAt: json['lastNotifyAt'] == null
      ? null
      : DateTime.parse(json['lastNotifyAt'] as String),
  extra: json['extra'] as Map<String, dynamic>?,
  deletedAt: json['deletedAt'] == null
      ? null
      : DateTime.parse(json['deletedAt'] as String),
);

Map<String, dynamic> _$PaymentOrderToJson(PaymentOrder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderNo': instance.orderNo,
      'userId': instance.userId,
      'agentId': instance.agentId,
      'bizType': _$BizTypeEnumMap[instance.bizType]!,
      'bizId': instance.bizId,
      'currency': instance.currency,
      'amount': instance.amount,
      'basePriceCny': instance.basePriceCny,
      'originalCurrency': instance.originalCurrency,
      'originalAmount': instance.originalAmount,
      'exchangeRate': instance.exchangeRate,
      'paymentPlatformId': instance.paymentPlatformId,
      'paymentChannelId': instance.paymentChannelId,
      'paymentPlatformOrderNo': instance.paymentPlatformOrderNo,
      'paymentMethod': instance.paymentMethod,
      'status': _$PaymentOrderStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'paidAt': instance.paidAt?.toIso8601String(),
      'expiredAt': instance.expiredAt?.toIso8601String(),
      'notifyCount': instance.notifyCount,
      'lastNotifyAt': instance.lastNotifyAt?.toIso8601String(),
      'extra': instance.extra,
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };

const _$BizTypeEnumMap = {
  BizType.recharge: 'recharge',
  BizType.resource: 'resource',
  BizType.vip: 'vip',
  BizType.timePackage: 'time_package',
};

const _$PaymentOrderStatusEnumMap = {
  PaymentOrderStatus.pending: 'pending',
  PaymentOrderStatus.success: 'success',
  PaymentOrderStatus.failed: 'failed',
  PaymentOrderStatus.closed: 'closed',
  PaymentOrderStatus.refunded: 'refunded',
};
