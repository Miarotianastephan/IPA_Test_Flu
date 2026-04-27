// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_feature_flags.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentFeatureFlags _$PaymentFeatureFlagsFromJson(Map<String, dynamic> json) =>
    PaymentFeatureFlags(
      longVideoPaymentsEnabled: json['long_video_payments_enabled'] == null
          ? true
          : parseBool(json['long_video_payments_enabled']),
      shortVideoPaymentsEnabled: json['short_video_payments_enabled'] == null
          ? true
          : parseBool(json['short_video_payments_enabled']),
      communityContentPaymentsEnabled:
          json['community_content_payments_enabled'] == null
          ? true
          : parseBool(json['community_content_payments_enabled']),
      vipFeaturesEnabled: json['vip_features_enabled'] == null
          ? true
          : parseBool(json['vip_features_enabled']),
      walletPaymentEnabled: json['wallet_payment_enabled'] == null
          ? true
          : parseBool(json['wallet_payment_enabled']),
      directPaymentEnabled: json['direct_payment_enabled'] == null
          ? true
          : parseBool(json['direct_payment_enabled']),
      videoPreviewEnabled: json['video_preview_enabled'] == null
          ? true
          : parseBool(json['video_preview_enabled']),
      previewDurationSeconds: json['preview_duration_seconds'] == null
          ? 120
          : parseInt(json['preview_duration_seconds']),
      dailyPreviewLimit: json['daily_preview_limit'] == null
          ? 3
          : parseInt(json['daily_preview_limit']),
      dailyFreeMinutes: json['daily_free_minutes'] == null
          ? 5
          : parseInt(json['daily_free_minutes']),
      minTimePackageMinutes: json['min_time_package_minutes'] == null
          ? 30
          : parseInt(json['min_time_package_minutes']),
      minRechargeAmount: parseDoubleOrNull(json['min_recharge_amount']),
      maxRechargeAmount: parseDoubleOrNull(json['max_recharge_amount']),
      orderExpirationMinutes: json['order_expiration_minutes'] == null
          ? 15
          : parseInt(json['order_expiration_minutes']),
      autoCancelExpiredOrders: json['auto_cancel_expired_orders'] == null
          ? true
          : parseBool(json['auto_cancel_expired_orders']),
    );

Map<String, dynamic> _$PaymentFeatureFlagsToJson(
  PaymentFeatureFlags instance,
) => <String, dynamic>{
  'long_video_payments_enabled': instance.longVideoPaymentsEnabled,
  'short_video_payments_enabled': instance.shortVideoPaymentsEnabled,
  'community_content_payments_enabled':
      instance.communityContentPaymentsEnabled,
  'vip_features_enabled': instance.vipFeaturesEnabled,
  'wallet_payment_enabled': instance.walletPaymentEnabled,
  'direct_payment_enabled': instance.directPaymentEnabled,
  'video_preview_enabled': instance.videoPreviewEnabled,
  'preview_duration_seconds': instance.previewDurationSeconds,
  'daily_preview_limit': instance.dailyPreviewLimit,
  'daily_free_minutes': instance.dailyFreeMinutes,
  'min_time_package_minutes': instance.minTimePackageMinutes,
  'min_recharge_amount': instance.minRechargeAmount,
  'max_recharge_amount': instance.maxRechargeAmount,
  'order_expiration_minutes': instance.orderExpirationMinutes,
  'auto_cancel_expired_orders': instance.autoCancelExpiredOrders,
};
