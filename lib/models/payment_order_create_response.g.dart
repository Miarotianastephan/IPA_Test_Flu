// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_order_create_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentOrderCreateResponse _$PaymentOrderCreateResponseFromJson(
  Map<String, dynamic> json,
) => PaymentOrderCreateResponse(
  orderId: json['orderId'] as String,
  payUrl: json['payUrl'] as String,
  payType: json['payType'] as String?,
  expiredAt: DateTime.parse(json['expiredAt'] as String),
);

Map<String, dynamic> _$PaymentOrderCreateResponseToJson(
  PaymentOrderCreateResponse instance,
) => <String, dynamic>{
  'orderId': instance.orderId,
  'payUrl': instance.payUrl,
  'payType': instance.payType,
  'expiredAt': instance.expiredAt.toIso8601String(),
};
