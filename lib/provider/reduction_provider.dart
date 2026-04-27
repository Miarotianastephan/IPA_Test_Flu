import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/api/services/reduction_service.dart';
import 'package:live_app/models/game_reduction_model.dart';
import 'package:live_app/provider/api_provider.dart';

class ReductionState {
  final bool isLoading;
  final String? error;
  final List<GameReductionResponse> reductionList;

  ReductionState({
    this.isLoading = false,
    this.error,
    this.reductionList = const [],
  });

  List<GameReductionResponse> get unclaimedReductions =>
      reductionList.where((r) => !r.hasReduction).toList();

  List<GameReductionResponse> get claimedReductions =>
      reductionList.where((r) => r.hasReduction).toList();

  bool get hasUnclaimedReductions => unclaimedReductions.isNotEmpty;

  ReductionState copyWith({
    bool? isLoading,
    String? error,
    List<GameReductionResponse>? reductionList,
  }) {
    return ReductionState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      reductionList: reductionList ?? this.reductionList,
    );
  }
}

class ReductionNotifier extends StateNotifier<ReductionState> {
  final ReductionService reductionService;

  ReductionNotifier(this.reductionService) : super(ReductionState());

  Future<void> loadReduction() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await reductionService.getGameReduce();
      if (response.success && response.data != null) {
        state = state.copyWith(reductionList: response.data, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      debugPrint("ReductionNotifier: Error loading reduction: $e");
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<String?> createUserReduction(int reductionId, bool claimed) async {
    try {
      final resp = await reductionService.createUserGameReduce(
        reductionId,
        claimed,
      );

      if (resp.data != null) {
        final url = resp.data!;
        final updatedList = state.reductionList.map((r) {
          if (r.gameReduction?.id == reductionId) {
            return GameReductionResponse(
              gameReduction: r.gameReduction,
              hasReduction: true,
            );
          }
          return r;
        }).toList();
        state = state.copyWith(reductionList: updatedList);

        if (url.startsWith('http://') || url.startsWith('https://')) {
          return url;
        }
        return null;
      }
      return null;
    } catch (e) {
      debugPrint("ReductionNotifier: Error creating user reduction: $e");
      return null;
    }
  }

  void reset() {
    state = ReductionState();
  }
}

final reductionServiceProvider = Provider<ReductionService>((ref) {
  final client = ref.watch(apiClientProvider);
  return ReductionService(client);
});

final reductionProvider =
    StateNotifierProvider<ReductionNotifier, ReductionState>((ref) {
      final reductionService = ref.watch(reductionServiceProvider);
      return ReductionNotifier(reductionService);
    });
