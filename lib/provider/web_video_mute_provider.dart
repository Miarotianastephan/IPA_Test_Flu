import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WebVideoMuteState {
  final bool isMuted;

  final bool hasShownUnmutePrompt;

  final bool hasUserInteracted;

  const WebVideoMuteState({
    this.isMuted = true,
    this.hasShownUnmutePrompt = false,
    this.hasUserInteracted = false,
  });

  bool get shouldShowUnmutePrompt =>
      kIsWeb && isMuted && !hasShownUnmutePrompt && !hasUserInteracted;

  WebVideoMuteState copyWith({
    bool? isMuted,
    bool? hasShownUnmutePrompt,
    bool? hasUserInteracted,
  }) {
    return WebVideoMuteState(
      isMuted: isMuted ?? this.isMuted,
      hasShownUnmutePrompt: hasShownUnmutePrompt ?? this.hasShownUnmutePrompt,
      hasUserInteracted: hasUserInteracted ?? this.hasUserInteracted,
    );
  }
}

class WebVideoMuteNotifier extends StateNotifier<WebVideoMuteState> {
  WebVideoMuteNotifier() : super(WebVideoMuteState(isMuted: kIsWeb));

  void toggleMute() {
    state = state.copyWith(isMuted: !state.isMuted, hasUserInteracted: true);
  }

  void setMuted(bool muted) {
    state = state.copyWith(isMuted: muted, hasUserInteracted: true);
  }

  void markUnmutePromptShown() {
    state = state.copyWith(hasShownUnmutePrompt: true);
  }
}

final webVideoMuteProvider =
    StateNotifierProvider<WebVideoMuteNotifier, WebVideoMuteState>(
      (ref) => WebVideoMuteNotifier(),
    );
