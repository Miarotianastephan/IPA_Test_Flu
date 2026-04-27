import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/utils/json_utils.dart';

part 'payment_channel.g.dart';

/// Payment channel status
enum PaymentChannelStatus {
  @JsonValue('active')
  active,
  @JsonValue('inactive')
  inactive,
}

/// Represents a payment channel (e.g., PayPal, Credit Card, Apple Pay)
@JsonSerializable(explicitToJson: true)
class PaymentChannel {
  @JsonKey(fromJson: parseInt)
  final int id;

  /// Associated payment platform ID
  @JsonKey(fromJson: parseInt)
  final int platformId;

  /// Channel code (e.g., 'PAYPAL_BALANCE', 'CREDIT_CARD', 'APPLE_PAY')
  final String channelCode;

  /// Display name (localized)
  final String name;

  /// i18n key for localization
  final String? i18nKey;

  /// Minimum transaction amount
  @JsonKey(fromJson: parseDouble)
  final double minAmount;

  /// Maximum transaction amount
  @JsonKey(fromJson: parseDouble)
  final double maxAmount;

  /// Currency code
  final String? currency;

  /// Allowed country codes (e.g., ['US', 'CN', 'GB'])
  @JsonKey(defaultValue: [])
  final List<String> countryCodes;

  /// Sort order for display
  @JsonKey(defaultValue: 0, fromJson: parseInt)
  final int sort;

  /// Channel status
  @JsonKey(defaultValue: PaymentChannelStatus.inactive)
  final PaymentChannelStatus status;

  /// Channel icon URL or asset path
  final String? icon;

  /// Channel configuration
  final Map<String, dynamic>? config;

  /// Created at timestamp
  final DateTime? createdAt;

  /// Updated at timestamp
  final DateTime? updatedAt;

  /// Deleted at timestamp
  final DateTime? deletedAt;

  PaymentChannel({
    required this.id,
    required this.platformId,
    required this.channelCode,
    required this.name,
    this.i18nKey,
    required this.minAmount,
    required this.maxAmount,
    this.currency,
    this.countryCodes = const [],
    this.sort = 0,
    this.status = PaymentChannelStatus.inactive,
    this.icon,
    this.config,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  /// Whether this channel is currently active
  bool get isActive => status == PaymentChannelStatus.active;

  /// Sort order (alias for sort field)
  int get sortOrder => sort;

  factory PaymentChannel.fromJson(Map<String, dynamic> json) =>
      _$PaymentChannelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentChannelToJson(this);

  PaymentChannel copyWith({
    int? id,
    int? platformId,
    String? channelCode,
    String? name,
    String? i18nKey,
    double? minAmount,
    double? maxAmount,
    String? currency,
    List<String>? countryCodes,
    int? sort,
    PaymentChannelStatus? status,
    String? icon,
    Map<String, dynamic>? config,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return PaymentChannel(
      id: id ?? this.id,
      platformId: platformId ?? this.platformId,
      channelCode: channelCode ?? this.channelCode,
      name: name ?? this.name,
      i18nKey: i18nKey ?? this.i18nKey,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      currency: currency ?? this.currency,
      countryCodes: countryCodes ?? this.countryCodes,
      sort: sort ?? this.sort,
      status: status ?? this.status,
      icon: icon ?? this.icon,
      config: config ?? this.config,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
