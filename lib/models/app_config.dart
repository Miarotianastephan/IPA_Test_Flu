import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/models/notif_chinese.dart';
import 'package:live_app/utils/json_utils.dart';

import 'payment_feature_flags.dart';

part 'app_config.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class AppConfig {
  @JsonKey(name: 'enable_video', defaultValue: true, fromJson: parseBool)
  final bool enableVideo;

  @JsonKey(name: 'enable_community', defaultValue: true, fromJson: parseBool)
  final bool enableCommunity;

  @JsonKey(name: 'enable_chat', defaultValue: false, fromJson: parseBool)
  final bool chatEnable;

  @JsonKey(name: 'chat_enable_group', defaultValue: true, fromJson: parseBool)
  final bool chatEnableGroup;

  @JsonKey(name: 'chat_enable_dm', defaultValue: true, fromJson: parseBool)
  final bool chatEnableDm;

  @JsonKey(name: 'chat_enable_paid', defaultValue: true, fromJson: parseBool)
  final bool chatEnablePaid;

  @JsonKey(name: 'chat_paid_price', defaultValue: 0, fromJson: parseInt)
  final int chatPaidPrice;

  @JsonKey(name: 'favicon_url', defaultValue: '')
  final String faviconUrl;

  @JsonKey(name: 'enable_web', defaultValue: true, fromJson: parseBool)
  final bool enableWeb;

  @JsonKey(name: 'enable_android', defaultValue: true, fromJson: parseBool)
  final bool enableAndroid;

  @JsonKey(name: 'enable_ios', defaultValue: true, fromJson: parseBool)
  final bool enableIos;

  @JsonKey(name: 'payment_feature_flags')
  final PaymentFeatureFlags? paymentFeatureFlags;

  @JsonKey(name: 'enable_game', defaultValue: true, fromJson: parseBool)
  final bool enableGame;

  @JsonKey(name: 'ads_after', defaultValue: 3, fromJson: parseInt)
  final int adsAfter;

  @JsonKey(name: 'text_notif', fromJson: parseNotifChinese)
  final NotifChinese? textNotif;

  @JsonKey(name: 'show_pricing', fromJson: parseBool, defaultValue: false)
  final bool showPricing;

  @JsonKey(name: 'reduction_interval', defaultValue: 60, fromJson: parseInt)
  final int reductionInterval;

  AppConfig({
    this.enableVideo = true,
    this.enableCommunity = true,
    this.chatEnable = false,
    this.chatEnableGroup = true,
    this.chatEnableDm = true,
    this.chatEnablePaid = true,
    this.chatPaidPrice = 0,
    this.faviconUrl = '',
    this.enableWeb = true,
    this.enableAndroid = true,
    this.enableIos = true,
    this.paymentFeatureFlags,
    this.enableGame = true,
    this.adsAfter = 3,
    this.textNotif,
    this.showPricing = false,
    this.reductionInterval = 60,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) =>
      _$AppConfigFromJson(json);

  Map<String, dynamic> toJson() => _$AppConfigToJson(this);

  factory AppConfig.defaults() => AppConfig();
}
