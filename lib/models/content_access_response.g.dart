// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_access_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContentAccessResponse _$ContentAccessResponseFromJson(
  Map<String, dynamic> json,
) => ContentAccessResponse(
  hasAccess: json['has_access'] == null ? false : parseBool(json['has_access']),
  reason: json['reason'] as String,
  price: parseDoubleOrNull(json['price']),
  originalPrice: parseDoubleOrNull(json['original_price']),
  discountRate: parseDoubleOrNull(json['discount_rate']),
  isVipDiscount: json['is_vip_discount'] == null
      ? false
      : parseBool(json['is_vip_discount']),
  previewDuration: parseIntOrNull(json['preview_duration']),
  previewsRemaining: parseIntOrNull(json['previews_remaining']),
  isPurchased: json['is_purchased'] == null
      ? false
      : parseBool(json['is_purchased']),
  isPaymentEnabled: json['is_payment_enabled'] == null
      ? true
      : parseBool(json['is_payment_enabled']),
);

Map<String, dynamic> _$ContentAccessResponseToJson(
  ContentAccessResponse instance,
) => <String, dynamic>{
  'has_access': instance.hasAccess,
  'reason': instance.reason,
  'price': instance.price,
  'original_price': instance.originalPrice,
  'discount_rate': instance.discountRate,
  'is_vip_discount': instance.isVipDiscount,
  'preview_duration': instance.previewDuration,
  'previews_remaining': instance.previewsRemaining,
  'is_purchased': instance.isPurchased,
  'is_payment_enabled': instance.isPaymentEnabled,
};
