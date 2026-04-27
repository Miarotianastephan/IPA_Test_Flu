import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/api/services/campaign_service.dart';
import 'package:live_app/models/user_progress.dart';

class UserProgressState {
  final UserProgress? userProgress;
  final bool isLoading;
  final String? error;

  UserProgressState({
    this.userProgress,
    this.isLoading = false,
    this.error,
  });

  UserProgressState copyWith({
    UserProgress? userProgress,
    bool? isLoading,
    String? error,
  }) {
    return UserProgressState(
      userProgress: userProgress ?? this.userProgress,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class UserProgressNotifier extends StateNotifier<UserProgressState> {
  final CampaignService campaignService;

  UserProgressNotifier(this.campaignService) : super(UserProgressState());

  Future<void> loadUserProgress({required int campaignId}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final resp = await campaignService.getUserProgress(campaignId: campaignId);

      final data = resp.data;
      if (data == null) throw Exception("Response data null");

      state = state.copyWith(
        userProgress: data,
        error: null,
      );
    } catch (e) {
      debugPrint("load user progress error: $e");
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void reset() {
    state = UserProgressState();
  }
}
