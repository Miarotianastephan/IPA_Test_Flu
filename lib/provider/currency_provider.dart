import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/currency_info.dart';
import 'api_provider.dart';

class CurrencyState {
  final CurrencyInfo? currencyInfo;
  final bool isLoading;
  final String? error;

  CurrencyState({this.currencyInfo, this.isLoading = false, this.error});

  CurrencyState copyWith({
    CurrencyInfo? currencyInfo,
    bool? isLoading,
    String? error,
  }) {
    return CurrencyState(
      currencyInfo: currencyInfo ?? this.currencyInfo,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  String get currencySymbol {
    return currencyInfo?.currencySymbol ?? '¥';
  }

  String get currencyCode {
    return currencyInfo?.currency ?? 'CNY';
  }

  double get exchangeRate {
    return currencyInfo?.rate ?? 1.0;
  }

  double convertFromBase(double baseAmount) {
    return currencyInfo?.convertFromBase(baseAmount) ?? baseAmount;
  }

  double convertToBase(double localAmount) {
    return currencyInfo?.convertToBase(localAmount) ?? localAmount;
  }

  String formatAmount(double amount, {int decimals = 2}) {
    return '$currencySymbol${amount.toStringAsFixed(decimals)}';
  }

  String formatBaseAmount(double baseAmount, {int decimals = 2}) {
    final localAmount = convertFromBase(baseAmount);
    return formatAmount(localAmount, decimals: decimals);
  }
}

class CurrencyNotifier extends StateNotifier<CurrencyState> {
  final Ref ref;

  CurrencyNotifier(this.ref) : super(CurrencyState()) {
    fetchCurrencyInfo();
  }

  Future<void> fetchCurrencyInfo({bool forceRefresh = false}) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final currencyService = ref.read(currencyServiceProvider);
      final response = await currencyService.getCurrencyInfo(
        forceRefresh: forceRefresh,
      );

      if (response.code == 1 && response.data != null) {
        state = state.copyWith(currencyInfo: response.data, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: response.msg);
      }
    } catch (e) {
      debugPrint('Error fetching currency info: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    await fetchCurrencyInfo(forceRefresh: true);
  }

  void clearCache() {
    final currencyService = ref.read(currencyServiceProvider);
    currencyService.clearCache();
    state = CurrencyState();
  }
}

final currencyProvider = StateNotifierProvider<CurrencyNotifier, CurrencyState>(
  (ref) {
    return CurrencyNotifier(ref);
  },
);
