import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/api/services/wingtop_game_service.dart';
import 'package:live_app/models/wallet_balance.dart';
import 'package:live_app/provider/api_provider.dart';
import 'package:live_app/provider/game_provider.dart';

class WingtopGameState {
  final bool isLoading;
  final String? error;
  final String? gameUrl;
  final double? gameCoins;
  final Map<String, dynamic>? firstRecharge;
  final double? totalRechargeAmount;
  final int? playDays;

  WingtopGameState({
    this.isLoading = false,
    this.error,
    this.gameUrl,
    this.gameCoins,
    this.firstRecharge,
    this.totalRechargeAmount,
    this.playDays,
  });

  WingtopGameState copyWith({
    bool? isLoading,
    String? error,
    String? gameUrl,
    double? gameCoins,
    Map<String, dynamic>? firstRecharge,
    double? totalRechargeAmount,
    int? playDays,
  }) {
    return WingtopGameState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      gameUrl: gameUrl ?? this.gameUrl,
      gameCoins: gameCoins ?? this.gameCoins,
      firstRecharge: firstRecharge ?? this.firstRecharge,
      totalRechargeAmount: totalRechargeAmount ?? this.totalRechargeAmount,
      playDays: playDays ?? this.playDays,
    );
  }
}

class WingtopGameNotifier extends StateNotifier<WingtopGameState> {
  final WingtopGameService gameService;
  final GameListNotifier gameListNotifier;

  WingtopGameNotifier(this.gameService, this.gameListNotifier)
      : super(WingtopGameState());

  Future<void> getGameCoinsBalance() async {
    try {
      final response = await gameService.getTotalRechargeAmount();

      if (response.success && response.data != null) {
        final amount = (response.data!['amount'] as num?)?.toDouble();
        state = state.copyWith(gameCoins: amount);
      }
    } catch (e) {
      debugPrint("WingtopGameNotifier: Error getting game coins: $e");
    }
  }

  Future<WalletBalance?> transferToGame({required double amount}) async {
    try {
      final response = await gameService.recharge(amount: amount);

      if (response.success) {
        await getGameCoinsBalance();
        return response.data;
      }
      return null;
    } catch (e) {
      debugPrint("WingtopGameNotifier: Transfer error: $e");
      return null;
    }
  }

  Future<void> loadFirstRecharge() async {
    try {
      final response = await gameService.getFirstRecharge();
      if (response.success && response.data != null) {
        state = state.copyWith(firstRecharge: response.data);
      }
    } catch (e) {
      debugPrint("WingtopGameNotifier: Error loading first recharge: $e");
    }
  }

  Future<void> loadTotalRechargeAmount() async {
    try {
      final response = await gameService.getTotalRechargeAmount();
      if (response.success && response.data != null) {
        final amount = (response.data!['amount'] as num?)?.toDouble();
        state = state.copyWith(totalRechargeAmount: amount);
      }
    } catch (e) {
      debugPrint("WingtopGameNotifier: Error loading total recharge: $e");
    }
  }

  Future<void> loadPlayDays() async {
    try {
      final response = await gameService.getPlayDays();
      if (response.success && response.data != null) {
        final days = int.tryParse(response.data!['playDays']?.toString() ?? '');
        state = state.copyWith(playDays: days);
      }
    } catch (e) {
      debugPrint("WingtopGameNotifier: Error loading play days: $e");
    }
  }

  Future<void> ensureGameLogin() async {
    if (state.gameUrl != null) return;
    try {
      final gameUrl = await gameListNotifier.loginGame();
      if (gameUrl != null) {
        state = state.copyWith(gameUrl: gameUrl);
      }
    } catch (e) {
      debugPrint("WingtopGameNotifier: Error ensuring game login: $e");
    }
  }

  Future<void> loadAllStats({bool forceLogin = false}) async {
    state = state.copyWith(isLoading: true);
    if (forceLogin || state.gameUrl == null) {
      await ensureGameLogin();
    }
    if (state.gameUrl == null) {
      debugPrint("WingtopGameNotifier: Skipping stats — game login not established");
      state = state.copyWith(isLoading: false);
      return;
    }
    await Future.wait([
      getGameCoinsBalance(),
      loadFirstRecharge(),
      loadTotalRechargeAmount(),
      loadPlayDays(),
    ]);
    state = state.copyWith(isLoading: false);
  }

  void setGameUrl(String url) {
    state = state.copyWith(gameUrl: url);
  }

  void clearGameUrl() {
    state = state.copyWith(gameUrl: null);
  }

  void reset() {
    state = WingtopGameState();
  }
}

final wingtopGameServiceProvider = Provider<WingtopGameService>((ref) {
  final client = ref.watch(apiClientProvider);
  return WingtopGameService(client);
});

final wingtopGameProvider =
    StateNotifierProvider<WingtopGameNotifier, WingtopGameState>((ref) {
      final gameService = ref.watch(wingtopGameServiceProvider);
      final gameListNotifier = ref.watch(gameListProvider.notifier);
      return WingtopGameNotifier(gameService, gameListNotifier);
    });
