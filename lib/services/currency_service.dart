import 'package:flutter/foundation.dart';

import '../api/services/base_service.dart';
import '../models/api_response.dart';
import '../models/currency_info.dart';
import '../utils/device_info_helper.dart';

class CurrencyService extends BaseService {
  CurrencyService(super.client);

  static const String _getCurrencyEndpoint =
      '/api/user/exchange-rates/get-currency';

  CurrencyInfo? _cachedCurrencyInfo;
  DateTime? _lastFetchTime;
  static const Duration _cacheExpiration = Duration(hours: 24);

  Future<ApiResponse<CurrencyInfo>> getCurrencyInfo({
    bool forceRefresh = false,
  }) async {
    // Check cache first
    if (!forceRefresh &&
        _cachedCurrencyInfo != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheExpiration) {
      return ApiResponse(
        code: 1,
        msg: 'Currency info from cache',
        data: _cachedCurrencyInfo,
      );
    }

    try {
      final ip =
          await DeviceInfoHelper.instance.getPublicIpAddress() ?? '0.0.0.0';

      final response = await post<CurrencyInfo>(
        _getCurrencyEndpoint,
        body: {'ip': ip},
        fromJson: (json) => CurrencyInfo.fromJson(json),
      );

      if (response.code == 1 && response.data != null) {
        _cachedCurrencyInfo = response.data;
        _lastFetchTime = DateTime.now();
      }

      return response;
    } catch (e) {
      debugPrint('Error fetching currency info: $e');

      if (_cachedCurrencyInfo != null) {
        return ApiResponse(
          code: 1,
          msg: 'Using cached currency info due to fetch error',
          data: _cachedCurrencyInfo,
        );
      }

      return ApiResponse(
        code: 0,
        msg: 'Using default CNY currency: $e',
        data: CurrencyInfo(ip: '0.0.0.0', rate: 1.0, currency: 'CNY'),
      );
    }
  }

  CurrencyInfo? getCachedCurrencyInfo() {
    return _cachedCurrencyInfo;
  }

  void clearCache() {
    _cachedCurrencyInfo = null;
    _lastFetchTime = null;
  }

  Future<double> convertToLocalCurrency(double baseAmount) async {
    final response = await getCurrencyInfo();
    if (response.code == 1 && response.data != null) {
      return response.data!.convertFromBase(baseAmount);
    }
    return baseAmount;
  }

  Future<double> convertToBaseCurrency(double localAmount) async {
    final response = await getCurrencyInfo();
    if (response.code == 1 && response.data != null) {
      return response.data!.convertToBase(localAmount);
    }
    return localAmount;
  }

  Future<String> getCurrencySymbol() async {
    final response = await getCurrencyInfo();
    if (response.code == 1 && response.data != null) {
      return response.data!.currencySymbol;
    }
    return '¥';
  }

  Future<String> getCurrencyCode() async {
    final response = await getCurrencyInfo();
    if (response.code == 1 && response.data != null) {
      return response.data!.currency;
    }
    return 'CNY';
  }
}
