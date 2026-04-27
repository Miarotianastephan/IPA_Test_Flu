import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_provider.dart';
import 'app_config_provider.dart';

class VideoPreviewState {
  final int remaining;
  final int total;
  final DateTime? resetAt;
  final bool isLoading;
  final String? error;

  VideoPreviewState({
    this.remaining = 0,
    this.total = 0,
    this.resetAt,
    this.isLoading = false,
    this.error,
  });

  bool get hasQuotaRemaining => remaining > 0;
  bool get quotaExhausted => remaining <= 0;

  VideoPreviewState copyWith({
    int? remaining,
    int? total,
    DateTime? resetAt,
    bool? isLoading,
    String? error,
  }) {
    return VideoPreviewState(
      remaining: remaining ?? this.remaining,
      total: total ?? this.total,
      resetAt: resetAt ?? this.resetAt,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class VideoPreviewNotifier extends StateNotifier<VideoPreviewState> {
  final Ref ref;

  VideoPreviewNotifier(this.ref) : super(VideoPreviewState()) {
    loadQuota();
  }

  Future<void> loadQuota() async {
    final userService = ref.read(userServiceProvider);

    try {
      state = state.copyWith(isLoading: true, error: null);
      final res = await userService.getPreviewQuota();

      if (res.data != null) {
        final data = res.data!;
        final remaining = data['remaining'] as int? ?? 0;

        final appConfig = ref.read(appConfigProvider);
        final total =
            appConfig.data?.paymentFeatureFlags?.dailyPreviewLimit ?? 10;

        state = state.copyWith(
          remaining: remaining,
          total: total,
          resetAt: data['resetAt'] != null
              ? DateTime.parse(data['resetAt'] as String)
              : null,
          isLoading: false,
        );
      }
    } catch (e) {
      debugPrint("Failed to load preview quota: $e");
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> recordPreview(String videoId) async {
    final userService = ref.read(userServiceProvider);

    try {
      final res = await userService.recordPreview(videoId);

      if (res.data != null) {
        await loadQuota();
        return true;
      }
    } catch (e) {
      debugPrint("Failed to record preview: $e");
      state = state.copyWith(error: e.toString());
    }

    return false;
  }

  bool canPreview() {
    return state.hasQuotaRemaining;
  }

  String getQuotaText() {
    if (state.quotaExhausted) {
      return 'No previews remaining today';
    }
    return '${state.remaining}/${state.total} previews remaining';
  }
}

extension VideoPreviewStateExtension on VideoPreviewState {
  String getQuotaText() {
    if (quotaExhausted) {
      return 'No previews remaining today';
    }
    return '$remaining/$total previews remaining';
  }
}

final videoPreviewProvider =
    StateNotifierProvider<VideoPreviewNotifier, VideoPreviewState>((ref) {
      return VideoPreviewNotifier(ref);
    });
