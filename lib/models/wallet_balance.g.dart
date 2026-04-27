// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_balance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletBalance _$WalletBalanceFromJson(Map<String, dynamic> json) =>
    WalletBalance(
      userId: json['user_id'] as String?,
      balance: parseDouble(json['balance']),
      currency: json['currency'] as String,
      status: json['status'] as String? ?? 'active',
      totalRecharged: json['total_recharged'] == null
          ? 0.0
          : parseDouble(json['total_recharged']),
      totalSpent: json['total_spent'] == null
          ? 0.0
          : parseDouble(json['total_spent']),
      frozenBalance: json['frozen_balance'] == null
          ? 0.0
          : parseDouble(json['frozen_balance']),
      updatedAt: parseDateTimeOrNull(json['updated_at']),
    );

Map<String, dynamic> _$WalletBalanceToJson(WalletBalance instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'balance': instance.balance,
      'currency': instance.currency,
      'status': instance.status,
      'total_recharged': instance.totalRecharged,
      'total_spent': instance.totalSpent,
      'frozen_balance': instance.frozenBalance,
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
