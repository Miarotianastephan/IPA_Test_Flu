import 'package:json_annotation/json_annotation.dart';

import '../utils/json_utils.dart';

part 'currency_info.g.dart';

/// Represents currency information based on user's IP address
/// Backend response from /api/user/get-currency: { ip, rate, currency }
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class CurrencyInfo {
  @JsonKey(defaultValue: '0.0.0.0')
  final String ip;
  @JsonKey(fromJson: parseDouble, defaultValue: 1.0)
  final double rate;

  @JsonKey(defaultValue: 'CNY')
  final String currency;

  CurrencyInfo({required this.ip, required this.rate, required this.currency});

  factory CurrencyInfo.fromJson(Map<String, dynamic> json) =>
      _$CurrencyInfoFromJson(json);

  Map<String, dynamic> toJson() => _$CurrencyInfoToJson(this);

  double convertFromBase(double baseAmount) {
    return baseAmount * rate;
  }

  double convertToBase(double localAmount) {
    return localAmount / rate;
  }

  String get currencySymbol {
    switch (currency.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'CNY':
      case 'RMB':
        return '¥';
      case 'JPY':
        return '¥';
      case 'KRW':
        return '₩';
      case 'INR':
        return '₹';
      case 'RUB':
        return '₽';
      case 'BRL':
        return 'R\$';
      case 'MXN':
        return 'Mex\$';
      case 'AUD':
        return 'A\$';
      case 'CAD':
        return 'C\$';
      case 'CHF':
        return 'CHF';
      case 'SEK':
        return 'kr';
      case 'NZD':
        return 'NZ\$';
      case 'SGD':
        return 'S\$';
      case 'HKD':
        return 'HK\$';
      case 'NOK':
        return 'kr';
      case 'MGA':
        return 'Ar';
      default:
        return currency;
    }
  }

  CurrencyInfo copyWith({String? ip, double? rate, String? currency}) {
    return CurrencyInfo(
      ip: ip ?? this.ip,
      rate: rate ?? this.rate,
      currency: currency ?? this.currency,
    );
  }
}
