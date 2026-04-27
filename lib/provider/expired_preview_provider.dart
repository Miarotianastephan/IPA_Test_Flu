import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpiredPreviewNotifier extends StateNotifier<Set<String>> {
  ExpiredPreviewNotifier() : super({});

  void markExpired(String videoId) {
    if (!state.contains(videoId)) {
      state = {...state, videoId};
    }
  }

  bool isExpired(String videoId) => state.contains(videoId);

  void clearExpired(String videoId) {
    if (state.contains(videoId)) {
      state = {...state}..remove(videoId);
    }
  }
}

final expiredPreviewProvider =
    StateNotifierProvider<ExpiredPreviewNotifier, Set<String>>((ref) {
      return ExpiredPreviewNotifier();
    });
