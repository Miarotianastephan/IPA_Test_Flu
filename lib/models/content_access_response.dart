import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/utils/json_utils.dart';

part 'content_access_response.g.dart';

/// Response from content access check API
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class ContentAccessResponse {
  /// Whether user has access to the content
  @JsonKey(defaultValue: false, fromJson: parseBool)
  final bool hasAccess;

  /// Reason for access status
  final String reason;

  /// Final price (after VIP discount)
  @JsonKey(fromJson: parseDoubleOrNull)
  final double? price;

  /// Original price (before discount)
  @JsonKey(fromJson: parseDoubleOrNull)
  final double? originalPrice;

  /// Discount rate applied (0.0 - 1.0)
  @JsonKey(fromJson: parseDoubleOrNull)
  final double? discountRate;

  /// Whether VIP discount was applied
  @JsonKey(defaultValue: false, fromJson: parseBool)
  final bool isVipDiscount;

  /// Preview duration in seconds (if previews available)
  @JsonKey(fromJson: parseIntOrNull)
  final int? previewDuration;

  /// Number of previews remaining today
  @JsonKey(fromJson: parseIntOrNull)
  final int? previewsRemaining;

  /// Whether user already purchased this content
  @JsonKey(defaultValue: false, fromJson: parseBool)
  final bool isPurchased;

  /// Whether payment is enabled for this content type
  @JsonKey(defaultValue: true, fromJson: parseBool)
  final bool isPaymentEnabled;

  ContentAccessResponse({
    this.hasAccess = false,
    required this.reason,
    this.price,
    this.originalPrice,
    this.discountRate,
    this.isVipDiscount = false,
    this.previewDuration,
    this.previewsRemaining,
    this.isPurchased = false,
    this.isPaymentEnabled = true,
  });

  factory ContentAccessResponse.fromJson(Map<String, dynamic> json) =>
      _$ContentAccessResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ContentAccessResponseToJson(this);

  /// Check if content requires payment
  bool get requiresPayment {
    return reason == 'payment_required' && !hasAccess && !isPurchased;
  }

  /// Check if previews are available
  bool get hasPreviewsAvailable {
    return previewsRemaining != null && previewsRemaining! > 0;
  }

  /// Get discount percentage
  int get discountPercentage {
    if (discountRate != null) {
      return (discountRate! * 100).round();
    }
    return 0;
  }

  /// Get discount amount
  double get discountAmount {
    if (originalPrice != null && price != null) {
      return originalPrice! - price!;
    }
    return 0.0;
  }

  ContentAccessResponse copyWith({
    bool? hasAccess,
    String? reason,
    double? price,
    double? originalPrice,
    double? discountRate,
    bool? isVipDiscount,
    int? previewDuration,
    int? previewsRemaining,
    bool? isPurchased,
    bool? isPaymentEnabled,
  }) {
    return ContentAccessResponse(
      hasAccess: hasAccess ?? this.hasAccess,
      reason: reason ?? this.reason,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      discountRate: discountRate ?? this.discountRate,
      isVipDiscount: isVipDiscount ?? this.isVipDiscount,
      previewDuration: previewDuration ?? this.previewDuration,
      previewsRemaining: previewsRemaining ?? this.previewsRemaining,
      isPurchased: isPurchased ?? this.isPurchased,
      isPaymentEnabled: isPaymentEnabled ?? this.isPaymentEnabled,
    );
  }
}
