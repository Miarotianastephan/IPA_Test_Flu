// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppConfig _$AppConfigFromJson(Map<String, dynamic> json) => AppConfig(
  enableVideo: json['enable_video'] == null
      ? true
      : parseBool(json['enable_video']),
  enableCommunity: json['enable_community'] == null
      ? true
      : parseBool(json['enable_community']),
  chatEnable: json['enable_chat'] == null
      ? false
      : parseBool(json['enable_chat']),
  chatEnableGroup: json['chat_enable_group'] == null
      ? true
      : parseBool(json['chat_enable_group']),
  chatEnableDm: json['chat_enable_dm'] == null
      ? true
      : parseBool(json['chat_enable_dm']),
  chatEnablePaid: json['chat_enable_paid'] == null
      ? true
      : parseBool(json['chat_enable_paid']),
  chatPaidPrice: json['chat_paid_price'] == null
      ? 0
      : parseInt(json['chat_paid_price']),
  faviconUrl: json['favicon_url'] as String? ?? '',
  enableWeb: json['enable_web'] == null ? true : parseBool(json['enable_web']),
  enableAndroid: json['enable_android'] == null
      ? true
      : parseBool(json['enable_android']),
  enableIos: json['enable_ios'] == null ? true : parseBool(json['enable_ios']),
  paymentFeatureFlags: json['payment_feature_flags'] == null
      ? null
      : PaymentFeatureFlags.fromJson(
          json['payment_feature_flags'] as Map<String, dynamic>,
        ),
  enableGame: json['enable_game'] == null
      ? true
      : parseBool(json['enable_game']),
  adsAfter: json['ads_after'] == null ? 3 : parseInt(json['ads_after']),
  textNotif: parseNotifChinese(json['text_notif']),
  showPricing: json['show_pricing'] == null
      ? false
      : parseBool(json['show_pricing']),
  reductionInterval: json['reduction_interval'] == null
      ? 60
      : parseInt(json['reduction_interval']),
);

Map<String, dynamic> _$AppConfigToJson(AppConfig instance) => <String, dynamic>{
  'enable_video': instance.enableVideo,
  'enable_community': instance.enableCommunity,
  'enable_chat': instance.chatEnable,
  'chat_enable_group': instance.chatEnableGroup,
  'chat_enable_dm': instance.chatEnableDm,
  'chat_enable_paid': instance.chatEnablePaid,
  'chat_paid_price': instance.chatPaidPrice,
  'favicon_url': instance.faviconUrl,
  'enable_web': instance.enableWeb,
  'enable_android': instance.enableAndroid,
  'enable_ios': instance.enableIos,
  'payment_feature_flags': instance.paymentFeatureFlags?.toJson(),
  'enable_game': instance.enableGame,
  'ads_after': instance.adsAfter,
  'text_notif': instance.textNotif?.toJson(),
  'show_pricing': instance.showPricing,
  'reduction_interval': instance.reductionInterval,
};
