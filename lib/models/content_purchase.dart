import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/utils/json_utils.dart';

part 'content_purchase.g.dart';

/// Content type for purchases
enum ContentType {
  @JsonValue('long_video')
  longVideo,

  @JsonValue('short_video')
  shortVideo,

  @JsonValue('audio')
  audio,

  @JsonValue('post')
  post,

  @JsonValue('article')
  article,

  @JsonValue('time_package')
  timePackage,
}

/// Purchase source (how user paid)
enum PurchaseSource {
  @JsonValue('wallet_debit')
  walletDebit,

  @JsonValue('direct_payment')
  directPayment,

  @JsonValue('vip_grant')
  vipGrant,

  @JsonValue('admin_grant')
  adminGrant,
}

/// Content purchase record
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class ContentPurchase {
  /// Purchase record ID
  final int id;

  /// User ID who made the purchase
  final String userId;

  /// Content type
  final ContentType contentType;

  /// Content ID (video ID, post ID, etc.)
  final int contentId;

  /// Purchase source
  final PurchaseSource purchaseSource;

  /// Price paid (after discounts)
  @JsonKey(fromJson: parseDouble)
  final double price;

  /// Original price (before discounts)
  @JsonKey(fromJson: parseDoubleOrNull)
  final double? originalPrice;

  /// Discount rate applied (0.0 - 1.0)
  @JsonKey(fromJson: parseDoubleOrNull)
  final double? discountRate;

  /// Whether VIP discount was applied
  @JsonKey(defaultValue: false, fromJson: parseBool)
  final bool isVipDiscount;

  /// Payment order ID (if direct payment)
  final int? orderId;

  /// Wallet transaction ID (if wallet debit)
  final int? walletTransactionId;

  /// VIP subscription ID (if VIP grant)
  final int? userVipId;

  /// Purchase timestamp
  final DateTime purchasedAt;

  /// Created timestamp
  final DateTime createdAt;

  /// Updated timestamp
  final DateTime updatedAt;

  ContentPurchase({
    required this.id,
    required this.userId,
    required this.contentType,
    required this.contentId,
    required this.purchaseSource,
    required this.price,
    this.originalPrice,
    this.discountRate,
    this.isVipDiscount = false,
    this.orderId,
    this.walletTransactionId,
    this.userVipId,
    required this.purchasedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ContentPurchase.fromJson(Map<String, dynamic> json) =>
      _$ContentPurchaseFromJson(json);

  Map<String, dynamic> toJson() => _$ContentPurchaseToJson(this);

  /// Check if discount was applied
  bool get hasDiscount {
    return originalPrice != null && originalPrice! > price;
  }

  /// Get discount amount
  double get discountAmount {
    if (!hasDiscount) return 0.0;
    return originalPrice! - price;
  }

  /// Get discount percentage
  int get discountPercentage {
    if (discountRate != null) {
      return (discountRate! * 100).round();
    }
    if (hasDiscount) {
      return ((discountAmount / originalPrice!) * 100).round();
    }
    return 0;
  }

  /// Get savings text
  String get savingsText {
    if (!hasDiscount) return '';
    return 'Saved \$${discountAmount.toStringAsFixed(2)} (${discountPercentage}%)';
  }

  ContentPurchase copyWith({
    int? id,
    String? userId,
    ContentType? contentType,
    int? contentId,
    PurchaseSource? purchaseSource,
    double? price,
    double? originalPrice,
    double? discountRate,
    bool? isVipDiscount,
    int? orderId,
    int? walletTransactionId,
    int? userVipId,
    DateTime? purchasedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ContentPurchase(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      contentType: contentType ?? this.contentType,
      contentId: contentId ?? this.contentId,
      purchaseSource: purchaseSource ?? this.purchaseSource,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      discountRate: discountRate ?? this.discountRate,
      isVipDiscount: isVipDiscount ?? this.isVipDiscount,
      orderId: orderId ?? this.orderId,
      walletTransactionId: walletTransactionId ?? this.walletTransactionId,
      userVipId: userVipId ?? this.userVipId,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
