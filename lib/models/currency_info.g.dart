// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CurrencyInfo _$CurrencyInfoFromJson(Map<String, dynamic> json) => CurrencyInfo(
  ip: json['ip'] as String? ?? '0.0.0.0',
  rate: json['rate'] == null ? 1.0 : parseDouble(json['rate']),
  currency: json['currency'] as String? ?? 'CNY',
);

Map<String, dynamic> _$CurrencyInfoToJson(CurrencyInfo instance) =>
    <String, dynamic>{
      'ip': instance.ip,
      'rate': instance.rate,
      'currency': instance.currency,
    };
