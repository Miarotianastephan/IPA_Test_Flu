import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/payment_feature_flags.dart';
import '../models/recharge_amount.dart';
import '../models/wallet_balance.dart';
import 'api_provider.dart';

class WalletState {
  final WalletBalance? balance;
  final List<RechargeAmount> rechargeAmounts;
  final bool isLoading;
  final String? error;
  final double? gameCoins;

  WalletState({
    this.balance,
    this.rechargeAmounts = const [],
    this.isLoading = false,
    this.error,
    this.gameCoins,
  });

  WalletState copyWith({
    WalletBalance? balance,
    List<RechargeAmount>? rechargeAmounts,
    bool? isLoading,
    String? error,
    double? gameCoins,
  }) {
    return WalletState(
      balance: balance ?? this.balance,
      rechargeAmounts: rechargeAmounts ?? this.rechargeAmounts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      gameCoins: gameCoins ?? this.gameCoins,
    );
  }
}

class WalletNotifier extends StateNotifier<WalletState> {
  final Ref ref;

  WalletNotifier(this.ref) : super(WalletState()) {
    _init();
  }

  Future<void> _init() async {
    await loadBalance();
  }

  Future<void> loadBalance() async {
    final paymentService = ref.read(paymentServiceProvider);

    try {
      state = state.copyWith(isLoading: true, error: null);
      final res = await paymentService.getWalletBalance();

      if (res.data != null) {
        state = state.copyWith(balance: res.data, isLoading: false);
      }
    } catch (e) {
      debugPrint("Failed to load wallet balance: $e");
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadRechargeAmounts() async {
    final paymentService = ref.read(paymentServiceProvider);

    try {
      final res = await paymentService.getRechargeAmounts(page: 1, limit: 100);

      if (res.data != null) {
        state = state.copyWith(rechargeAmounts: res.data!.list);
      }
    } catch (e) {
      debugPrint("Failed to load recharge amounts: $e");
    }
  }

  Future<void> refresh() async {
    await loadBalance();
  }

  bool hasSufficientBalance(double amount) {
    if (state.balance == null) return false;
    return state.balance!.hasSufficientBalance(amount);
  }

  double get availableBalance {
    return state.balance?.availableBalance ?? 0.0;
  }

  void updateGameCoins(double? coins) {
    state = state.copyWith(gameCoins: coins);
  }

  double? get gameCoinsBalance => state.gameCoins;
}

final walletProvider = StateNotifierProvider<WalletNotifier, WalletState>((
  ref,
) {
  return WalletNotifier(ref);
});

final paymentFeatureFlagsProvider = FutureProvider<PaymentFeatureFlags>((
  ref,
) async {
  final paymentService = ref.read(paymentServiceProvider);

  try {
    final res = await paymentService.getFeatureFlags();
    return res.data ?? PaymentFeatureFlags.defaults();
  } catch (e) {
    debugPrint("Failed to load payment feature flags: $e");
    return PaymentFeatureFlags.defaults();
  }
});
