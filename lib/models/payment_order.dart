import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/utils/json_utils.dart';

part 'payment_order.g.dart';

/// Business type enum
enum BizType {
  @JsonValue('recharge')
  recharge,
  @JsonValue('resource')
  resource,
  @JsonValue('vip')
  vip,
  @JsonValue('time_package')
  timePackage,
}

/// Payment order status
enum PaymentOrderStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('success')
  success,
  @JsonValue('failed')
  failed,
  @JsonValue('closed')
  closed,
  @JsonValue('refunded')
  refunded,
}

/// Represents a payment order in the system
@JsonSerializable(explicitToJson: true)
class PaymentOrder {
  /// Snowflake ID
  final String id;

  /// Unique order number
  final String orderNo;

  /// User ID who created this order
  final String userId;

  /// Agent ID (optional)
  final String? agentId;

  /// Business type
  final BizType bizType;

  /// Business resource ID (optional)
  final String? bizId;

  /// Transaction currency
  @JsonKey(defaultValue: 'CNY')
  final String currency;

  /// Amount paid
  @JsonKey(fromJson: parseDouble)
  final double amount;

  /// Base price in CNY
  @JsonKey(fromJson: parseDouble)
  final double basePriceCny;

  /// Original currency if conversion applied
  final String? originalCurrency;

  /// Original amount if conversion applied
  @JsonKey(fromJson: parseDoubleOrNull)
  final double? originalAmount;

  /// Exchange rate applied
  @JsonKey(fromJson: parseDoubleOrNull)
  final double? exchangeRate;

  /// Payment platform ID
  @JsonKey(fromJson: parseInt)
  final int paymentPlatformId;

  /// Payment channel ID (optional)
  @JsonKey(fromJson: parseIntOrNull)
  final int? paymentChannelId;

  /// Payment platform order number (e.g., Huitong transaction number)
  final String? paymentPlatformOrderNo;

  /// Payment method used
  final String? paymentMethod;

  /// Current order status
  @JsonKey(defaultValue: PaymentOrderStatus.pending)
  final PaymentOrderStatus status;

  /// Order creation time
  final DateTime createdAt;

  /// Payment success time
  final DateTime? paidAt;

  /// Order expiration time
  final DateTime? expiredAt;

  /// Number of webhooks received
  @JsonKey(defaultValue: 0)
  final int notifyCount;

  /// Last webhook received time
  final DateTime? lastNotifyAt;

  /// Additional data
  final Map<String, dynamic>? extra;

  /// Deleted at timestamp
  final DateTime? deletedAt;

  PaymentOrder({
    required this.id,
    required this.orderNo,
    required this.userId,
    this.agentId,
    required this.bizType,
    this.bizId,
    this.currency = 'CNY',
    required this.amount,
    required this.basePriceCny,
    this.originalCurrency,
    this.originalAmount,
    this.exchangeRate,
    required this.paymentPlatformId,
    this.paymentChannelId,
    this.paymentPlatformOrderNo,
    this.paymentMethod,
    this.status = PaymentOrderStatus.pending,
    required this.createdAt,
    this.paidAt,
    this.expiredAt,
    this.notifyCount = 0,
    this.lastNotifyAt,
    this.extra,
    this.deletedAt,
  });

  factory PaymentOrder.fromJson(Map<String, dynamic> json) =>
      _$PaymentOrderFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentOrderToJson(this);

  PaymentOrder copyWith({
    String? id,
    String? orderNo,
    String? userId,
    String? agentId,
    BizType? bizType,
    String? bizId,
    String? currency,
    double? amount,
    double? basePriceCny,
    String? originalCurrency,
    double? originalAmount,
    double? exchangeRate,
    int? paymentPlatformId,
    int? paymentChannelId,
    String? paymentPlatformOrderNo,
    String? paymentMethod,
    PaymentOrderStatus? status,
    DateTime? createdAt,
    DateTime? paidAt,
    DateTime? expiredAt,
    int? notifyCount,
    DateTime? lastNotifyAt,
    Map<String, dynamic>? extra,
    DateTime? deletedAt,
  }) {
    return PaymentOrder(
      id: id ?? this.id,
      orderNo: orderNo ?? this.orderNo,
      userId: userId ?? this.userId,
      agentId: agentId ?? this.agentId,
      bizType: bizType ?? this.bizType,
      bizId: bizId ?? this.bizId,
      currency: currency ?? this.currency,
      amount: amount ?? this.amount,
      basePriceCny: basePriceCny ?? this.basePriceCny,
      originalCurrency: originalCurrency ?? this.originalCurrency,
      originalAmount: originalAmount ?? this.originalAmount,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      paymentPlatformId: paymentPlatformId ?? this.paymentPlatformId,
      paymentChannelId: paymentChannelId ?? this.paymentChannelId,
      paymentPlatformOrderNo:
          paymentPlatformOrderNo ?? this.paymentPlatformOrderNo,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      paidAt: paidAt ?? this.paidAt,
      expiredAt: expiredAt ?? this.expiredAt,
      notifyCount: notifyCount ?? this.notifyCount,
      lastNotifyAt: lastNotifyAt ?? this.lastNotifyAt,
      extra: extra ?? this.extra,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  /// Check if order is still valid (not expired)
  bool get isValid {
    if (expiredAt == null) return true;
    return DateTime.now().isBefore(expiredAt!);
  }

  /// Check if order is in a final state
  bool get isFinal {
    return status == PaymentOrderStatus.success ||
        status == PaymentOrderStatus.failed ||
        status == PaymentOrderStatus.closed ||
        status == PaymentOrderStatus.refunded;
  }

  /// Check if payment was successful
  bool get isSuccessful => status == PaymentOrderStatus.success;

  /// Check if payment is pending
  bool get isPending => status == PaymentOrderStatus.pending;

  /// Check if payment failed
  bool get isFailed => status == PaymentOrderStatus.failed;
}
