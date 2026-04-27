import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/utils/json_utils.dart';

part 'recharge_amount.g.dart';

/// Represents a predefined recharge amount option
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class RechargeAmount {
  @JsonKey(fromJson: parseInt)
  final int id;

  /// Recharge amount in base currency (RMB)
  @JsonKey(fromJson: parseDouble)
  final double amount;

  /// Currency code
  final String currency;

  /// Bonus amount (promotional)
  @JsonKey(fromJson: parseDouble, defaultValue: 0.0)
  final double bonusAmount;

  /// Total amount user receives (amount + bonusAmount)
  double get totalAmount => amount + bonusAmount;

  /// Bonus percentage (for display)
  int get bonusPercentage =>
      bonusAmount > 0 ? ((bonusAmount / amount) * 100).round() : 0;

  /// Whether this option is recommended/popular
  @JsonKey(defaultValue: false, fromJson: parseBool)
  final bool isPopular;

  /// Display label (e.g., "Best Value", "Most Popular")
  final String? label;

  /// Sort order for display
  @JsonKey(defaultValue: 0, fromJson: parseInt)
  final int sortOrder;

  /// Associated agent ID (for multi-tenant support)
  @JsonKey(fromJson: parseInt)
  final int agentId;

  /// Whether this option is currently active
  @JsonKey(defaultValue: true, fromJson: parseBool)
  final bool isActive;

  RechargeAmount({
    required this.id,
    required this.amount,
    required this.currency,
    this.bonusAmount = 0.0,
    this.isPopular = false,
    this.label,
    this.sortOrder = 0,
    required this.agentId,
    this.isActive = true,
  });

  factory RechargeAmount.fromJson(Map<String, dynamic> json) =>
      _$RechargeAmountFromJson(json);

  Map<String, dynamic> toJson() => _$RechargeAmountToJson(this);

  RechargeAmount copyWith({
    int? id,
    double? amount,
    String? currency,
    double? bonusAmount,
    bool? isPopular,
    String? label,
    int? sortOrder,
    int? agentId,
    bool? isActive,
  }) {
    return RechargeAmount(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      bonusAmount: bonusAmount ?? this.bonusAmount,
      isPopular: isPopular ?? this.isPopular,
      label: label ?? this.label,
      sortOrder: sortOrder ?? this.sortOrder,
      agentId: agentId ?? this.agentId,
      isActive: isActive ?? this.isActive,
    );
  }
}
