import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/utils/json_utils.dart';

part 'wallet_transaction.g.dart';

/// Transaction type (credit = recharge, debit = purchase)
enum TransactionType {
  @JsonValue('credit')
  credit,
  @JsonValue('debit')
  debit,
}

/// Transaction category
enum TransactionCategory {
  @JsonValue('recharge')
  recharge,
  @JsonValue('purchase')
  purchase,
  @JsonValue('refund')
  refund,
  @JsonValue('adjustment')
  adjustment,
}

/// Represents a wallet transaction
/// Backend response from /wallet/transactions
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class WalletTransaction {
  /// Transaction ID (snowflake)
  final String id;

  /// Transaction type (credit or debit)
  final TransactionType type;

  /// Transaction category (recharge, purchase, etc.)
  final TransactionCategory category;

  /// Transaction amount
  @JsonKey(fromJson: parseDouble)
  final double amount;

  /// Balance before transaction
  @JsonKey(fromJson: parseDouble)
  final double balanceBefore;

  /// Balance after transaction
  @JsonKey(fromJson: parseDouble)
  final double balanceAfter;

  /// Transaction description
  final String description;

  /// Transaction creation time
  final DateTime createdAt;

  WalletTransaction({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.description,
    required this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) =>
      _$WalletTransactionFromJson(json);

  Map<String, dynamic> toJson() => _$WalletTransactionToJson(this);
}
