import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/userinfo.dart';

import '../provider/api_provider.dart';
import '../provider/current_user_provider.dart';

class CumulativeWatchTimeState {
  final int watchedSeconds;
  final int limitSeconds;
  final bool hasShownLimitPopup;
  final bool isLimitReached;

  const CumulativeWatchTimeState({
    this.watchedSeconds = 0,
    this.limitSeconds = 0,
    this.hasShownLimitPopup = false,
    this.isLimitReached = false,
  });

  int get remainingSeconds =>
      (limitSeconds - watchedSeconds).clamp(0, limitSeconds);

  bool get shouldBlockPlayback => remainingSeconds <= 0;

  CumulativeWatchTimeState copyWith({
    int? watchedSeconds,
    int? limitSeconds,
    bool? hasShownLimitPopup,
    bool? isLimitReached,
  }) {
    return CumulativeWatchTimeState(
      watchedSeconds: watchedSeconds ?? this.watchedSeconds,
      limitSeconds: limitSeconds ?? this.limitSeconds,
      hasShownLimitPopup: hasShownLimitPopup ?? this.hasShownLimitPopup,
      isLimitReached: isLimitReached ?? this.isLimitReached,
    );
  }

  String get formattedRemainingTime {
    final int hours = remainingSeconds ~/ 3600;
    final int minutes = (remainingSeconds % 3600) ~/ 60;
    final int seconds = remainingSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }
}

class CumulativeWatchTimeNotifier
    extends StateNotifier<CumulativeWatchTimeState> {
  final Ref ref;
  bool _isTracking = false;
  String? _activeVideoId;
  bool _isSyncing = false;
  int _pendingPlaybackMillis = 0;

  CumulativeWatchTimeNotifier(this.ref)
    : super(const CumulativeWatchTimeState()) {
    final user = ref.read(currentUserProvider);
    _updateFromUser(user);

    ref.listen<UserInfo?>(currentUserProvider, (_, next) {
      _updateFromUser(next);
    });

    if (kIsWeb) {
      _initializeWebLifecycleDetection();
    }
  }

  void _updateFromUser(UserInfo? user) {
    if (user != null) {
      final daily = user.dailyWatchTimeLeft ?? 0;
      final extra = user.extraWatchTimeLeft ?? 0;
      final total = daily + extra;

      if (_isTracking) {
        state = state.copyWith(
          limitSeconds: total,
          isLimitReached: total <= state.watchedSeconds,
        );
      } else {
        final currentWatched = state.watchedSeconds;
        state = state.copyWith(
          limitSeconds: total,
          watchedSeconds: currentWatched,
          isLimitReached: total <= currentWatched,
          hasShownLimitPopup: total > 0 ? false : state.hasShownLimitPopup,
        );
      }
    }
  }

  void startTracking({String? videoId}) {
    if (state.shouldBlockPlayback) return;
    if (videoId != null) {
      _activeVideoId = videoId;
    }
    _isTracking = true;
  }

  void addPlaybackDuration({required Duration duration, String? videoId}) {
    if (!_isTracking || state.shouldBlockPlayback) return;
    if (videoId != null &&
        _activeVideoId != null &&
        _activeVideoId != videoId) {
      return;
    }

    final deltaMillis = duration.inMilliseconds;
    if (deltaMillis <= 0) return;

    _pendingPlaybackMillis += deltaMillis;
    final secondsToAdd = _pendingPlaybackMillis ~/ 1000;
    if (secondsToAdd <= 0) return;

    _pendingPlaybackMillis -= secondsToAdd * 1000;

    final safeSecondsToAdd = secondsToAdd
        .clamp(0, state.remainingSeconds)
        .toInt();
    if (safeSecondsToAdd <= 0) {
      _pendingPlaybackMillis = 0;
      unawaited(stopTracking(videoId: videoId));
      return;
    }

    final newWatched = state.watchedSeconds + safeSecondsToAdd;
    final isLimitReached = newWatched >= state.limitSeconds;

    state = state.copyWith(
      watchedSeconds: newWatched,
      isLimitReached: isLimitReached,
    );

    if (isLimitReached) {
      _pendingPlaybackMillis = 0;
      unawaited(stopTracking(videoId: videoId));
    }
  }

  void pauseTracking({String? videoId}) {
    if (videoId != null && _activeVideoId != videoId) return;
    _isTracking = false;
  }

  Future<void> stopTracking({String? videoId}) async {
    if (videoId != null && _activeVideoId != videoId) return;
    _isTracking = false;
    _activeVideoId = null;
    _pendingPlaybackMillis = 0;

    if (state.watchedSeconds > 0) {
      await _syncWithServer();
    }
  }

  Future<void> _syncWithServer() async {
    if (_isSyncing) return;

    _isSyncing = true;
    try {
      final consumed = state.watchedSeconds;
      if (consumed <= 0) return;

      final userService = ref.read(userServiceProvider);
      final res = await userService.updateRemainingTime(duration: consumed);

      if (res.data != null) {
        await ref.read(currentUserProvider.notifier).syncUser(res.data!);
        state = state.copyWith(watchedSeconds: 0);
      }
    } catch (e) {
      debugPrint("Failed to sync watch time: $e");
    } finally {
      _isSyncing = false;
    }
  }

  void markPopupShown() {
    state = state.copyWith(hasShownLimitPopup: true);
  }

  Future<void> reset() async {
    await stopTracking();
    state = state.copyWith(hasShownLimitPopup: false);
  }

  void _initializeWebLifecycleDetection() {
    if (kIsWeb) {
      _startPeriodicWebSync();
    }
  }

  void _startPeriodicWebSync() {
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isTracking && state.watchedSeconds > 0) {
        _syncWithServer();
      }
    });
  }

  @override
  void dispose() {
    if (kIsWeb && _isTracking && state.watchedSeconds > 0 && !_isSyncing) {
      _syncWithServer();
    }

    super.dispose();
  }
}

final cumulativeWatchTimeProvider =
    StateNotifierProvider<
      CumulativeWatchTimeNotifier,
      CumulativeWatchTimeState
    >((ref) {
      return CumulativeWatchTimeNotifier(ref);
    });
