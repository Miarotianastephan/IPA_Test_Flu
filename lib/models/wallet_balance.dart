import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/utils/json_utils.dart';

part 'wallet_balance.g.dart';

/// Represents user's wallet balance information
/// Backend response: { success: true, data: { balance, currency, status } }
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class WalletBalance {
  final String? userId;

  /// Current wallet balance (1:1 with currency)
  @JsonKey(fromJson: parseDouble)
  final double balance;

  /// Currency code for the balance (CNY, USD, etc.)
  final String currency;

  /// Wallet status (active, suspended, etc.)
  @JsonKey(defaultValue: 'active')
  final String status;

  /// Total amount recharged (lifetime) - optional field
  @JsonKey(fromJson: parseDouble, defaultValue: 0.0)
  final double totalRecharged;

  /// Total amount spent (lifetime) - optional field
  @JsonKey(fromJson: parseDouble, defaultValue: 0.0)
  final double totalSpent;

  /// Frozen/locked balance (e.g., pending transactions) - optional field
  @JsonKey(fromJson: parseDouble, defaultValue: 0.0)
  final double frozenBalance;

  /// Available balance (balance - frozenBalance)
  double get availableBalance => balance - frozenBalance;

  /// Last update time - optional field
  @JsonKey(fromJson: parseDateTimeOrNull)
  final DateTime? updatedAt;

  WalletBalance({
    this.userId,
    required this.balance,
    required this.currency,
    this.status = 'active',
    this.totalRecharged = 0.0,
    this.totalSpent = 0.0,
    this.frozenBalance = 0.0,
    this.updatedAt,
  });

  factory WalletBalance.fromJson(Map<String, dynamic> json) =>
      _$WalletBalanceFromJson(json);

  Map<String, dynamic> toJson() => _$WalletBalanceToJson(this);

  WalletBalance copyWith({
    String? userId,
    double? balance,
    String? currency,
    String? status,
    double? totalRecharged,
    double? totalSpent,
    double? frozenBalance,
    DateTime? updatedAt,
  }) {
    return WalletBalance(
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      totalRecharged: totalRecharged ?? this.totalRecharged,
      totalSpent: totalSpent ?? this.totalSpent,
      frozenBalance: frozenBalance ?? this.frozenBalance,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if user has sufficient balance for a purchase
  bool hasSufficientBalance(double amount) {
    return availableBalance >= amount;
  }
}
