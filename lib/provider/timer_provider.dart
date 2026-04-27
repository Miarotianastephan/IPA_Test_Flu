import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TimerState {
  final int seconds;
  final bool isRunning;
  final bool isPaused;

  TimerState({
    this.seconds = 0,
    this.isRunning = false,
    this.isPaused = false,
  });

  TimerState copyWith({
    int? seconds,
    bool? isRunning,
    bool? isPaused,
  }) {
    return TimerState(
      seconds: seconds ?? this.seconds,
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
    );
  }

  String get formattedTime {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }
}

class TimerNotifier extends StateNotifier<TimerState> {
  TimerNotifier() : super(TimerState());

  Timer? _timer;

  void start() {
    if (state.isRunning && !state.isPaused) return;

    if (state.isPaused) {
      // Resume from paused state
      state = state.copyWith(
        isRunning: true,
        isPaused: false,
      );
    } else {
      // Start fresh
      state = state.copyWith(
        seconds: 0,
        isRunning: true,
        isPaused: false,
      );
    }

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      state = state.copyWith(seconds: state.seconds + 1);
    });
  }

  void pause() {
    if (!state.isRunning || state.isPaused) return;

    _timer?.cancel();
    state = state.copyWith(
      isRunning: false,
      isPaused: true,
    );
  }

  void resume() {
    if (!state.isPaused) return;
    start();
  }

  void stop() {
    _timer?.cancel();
    state = state.copyWith(
      seconds: 0,
      isRunning: false,
      isPaused: false,
    );
  }

  void reset() {
    _timer?.cancel();
    state = state.copyWith(
      seconds: 0,
      isRunning: false,
      isPaused: false,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Timer provider for tracking compte time
final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  return TimerNotifier();
});
