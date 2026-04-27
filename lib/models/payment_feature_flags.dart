import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/utils/json_utils.dart';

part 'payment_feature_flags.g.dart';

/// Payment feature configuration flags from backend
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class PaymentFeatureFlags {
  /// Enable/disable long video payments
  @JsonKey(
    name: "long_video_payments_enabled",
    defaultValue: true,
    fromJson: parseBool,
  )
  final bool longVideoPaymentsEnabled;

  /// Enable/disable short video payments
  @JsonKey(
    name: "short_video_payments_enabled",
    defaultValue: true,
    fromJson: parseBool,
  )
  final bool shortVideoPaymentsEnabled;

  /// Enable/disable community content payments
  @JsonKey(
    name: "community_content_payments_enabled",
    defaultValue: true,
    fromJson: parseBool,
  )
  final bool communityContentPaymentsEnabled;

  /// Enable/disable VIP features
  @JsonKey(
    name: "vip_features_enabled",
    defaultValue: true,
    fromJson: parseBool,
  )
  final bool vipFeaturesEnabled;

  /// Enable/disable wallet payment method
  @JsonKey(
    name: "wallet_payment_enabled",
    defaultValue: true,
    fromJson: parseBool,
  )
  final bool walletPaymentEnabled;

  /// Enable/disable direct payment method
  @JsonKey(
    name: "direct_payment_enabled",
    defaultValue: true,
    fromJson: parseBool,
  )
  final bool directPaymentEnabled;

  // === Preview Settings ===

  /// Enable/disable video preview functionality
  @JsonKey(
    name: "video_preview_enabled",
    defaultValue: true,
    fromJson: parseBool,
  )
  final bool videoPreviewEnabled;

  /// Preview duration in seconds (e.g., 120 = 2 minutes)
  @JsonKey(
    name: "preview_duration_seconds",
    defaultValue: 120,
    fromJson: parseInt,
  )
  final int previewDurationSeconds;

  /// Daily preview limit per user/device (e.g., 3 previews per day)
  @JsonKey(name: "daily_preview_limit", defaultValue: 3, fromJson: parseInt)
  final int dailyPreviewLimit;

  // === Short Video Settings ===

  /// Daily free minutes for short videos (e.g., 5 minutes)
  @JsonKey(name: "daily_free_minutes", defaultValue: 5, fromJson: parseInt)
  final int dailyFreeMinutes;

  /// Minimum time package in minutes (e.g., 30)
  @JsonKey(
    name: "min_time_package_minutes",
    defaultValue: 30,
    fromJson: parseInt,
  )
  final int minTimePackageMinutes;

  // === Payment Settings ===

  /// Minimum recharge amount
  @JsonKey(name: "min_recharge_amount", fromJson: parseDoubleOrNull)
  final double? minRechargeAmount;

  /// Maximum recharge amount
  @JsonKey(name: "max_recharge_amount", fromJson: parseDoubleOrNull)
  final double? maxRechargeAmount;

  /// Payment order expiration time in minutes (default: 15)
  @JsonKey(
    name: "order_expiration_minutes",
    defaultValue: 15,
    fromJson: parseInt,
  )
  final int orderExpirationMinutes;

  /// Auto-cancel expired orders
  @JsonKey(
    name: "auto_cancel_expired_orders",
    defaultValue: true,
    fromJson: parseBool,
  )
  final bool autoCancelExpiredOrders;

  PaymentFeatureFlags({
    this.longVideoPaymentsEnabled = true,
    this.shortVideoPaymentsEnabled = true,
    this.communityContentPaymentsEnabled = true,
    this.vipFeaturesEnabled = true,
    this.walletPaymentEnabled = true,
    this.directPaymentEnabled = true,
    this.videoPreviewEnabled = true,
    this.previewDurationSeconds = 120,
    this.dailyPreviewLimit = 3,
    this.dailyFreeMinutes = 5,
    this.minTimePackageMinutes = 30,
    this.minRechargeAmount,
    this.maxRechargeAmount,
    this.orderExpirationMinutes = 15,
    this.autoCancelExpiredOrders = true,
  });

  factory PaymentFeatureFlags.fromJson(Map<String, dynamic> json) =>
      _$PaymentFeatureFlagsFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentFeatureFlagsToJson(this);

  /// Default configuration (all features enabled)
  factory PaymentFeatureFlags.defaults() {
    return PaymentFeatureFlags();
  }

  PaymentFeatureFlags copyWith({
    bool? longVideoPaymentsEnabled,
    bool? shortVideoPaymentsEnabled,
    bool? communityContentPaymentsEnabled,
    bool? vipFeaturesEnabled,
    bool? walletPaymentEnabled,
    bool? directPaymentEnabled,
    bool? videoPreviewEnabled,
    int? previewDurationSeconds,
    int? dailyPreviewLimit,
    int? dailyFreeMinutes,
    int? minTimePackageMinutes,
    double? minRechargeAmount,
    double? maxRechargeAmount,
    int? orderExpirationMinutes,
    bool? autoCancelExpiredOrders,
  }) {
    return PaymentFeatureFlags(
      longVideoPaymentsEnabled:
          longVideoPaymentsEnabled ?? this.longVideoPaymentsEnabled,
      shortVideoPaymentsEnabled:
          shortVideoPaymentsEnabled ?? this.shortVideoPaymentsEnabled,
      communityContentPaymentsEnabled:
          communityContentPaymentsEnabled ??
          this.communityContentPaymentsEnabled,
      vipFeaturesEnabled: vipFeaturesEnabled ?? this.vipFeaturesEnabled,
      walletPaymentEnabled: walletPaymentEnabled ?? this.walletPaymentEnabled,
      directPaymentEnabled: directPaymentEnabled ?? this.directPaymentEnabled,
      videoPreviewEnabled: videoPreviewEnabled ?? this.videoPreviewEnabled,
      previewDurationSeconds:
          previewDurationSeconds ?? this.previewDurationSeconds,
      dailyPreviewLimit: dailyPreviewLimit ?? this.dailyPreviewLimit,
      dailyFreeMinutes: dailyFreeMinutes ?? this.dailyFreeMinutes,
      minTimePackageMinutes:
          minTimePackageMinutes ?? this.minTimePackageMinutes,
      minRechargeAmount: minRechargeAmount ?? this.minRechargeAmount,
      maxRechargeAmount: maxRechargeAmount ?? this.maxRechargeAmount,
      orderExpirationMinutes:
          orderExpirationMinutes ?? this.orderExpirationMinutes,
      autoCancelExpiredOrders:
          autoCancelExpiredOrders ?? this.autoCancelExpiredOrders,
    );
  }
}
