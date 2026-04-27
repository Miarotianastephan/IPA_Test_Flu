import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/api/services/ad_video_service.dart';
import 'package:live_app/models/ad_video_config.dart';
import 'package:live_app/provider/api_provider.dart';
import 'package:live_app/services/ad_video_preload_service.dart';

class AdVideoListState {
  final List<AdVideoConfig> adVideoConfigs;
  final bool isLoading;
  final String? error;
  final bool hasMore;

  AdVideoListState({
    this.adVideoConfigs = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
  });

  AdVideoListState copyWith({
    List<AdVideoConfig>? adVideoConfigs,
    bool? isLoading,
    String? error,
    bool? hasMore,
  }) {
    return AdVideoListState(
      adVideoConfigs: adVideoConfigs ?? this.adVideoConfigs,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class AdVideoListNotifier extends StateNotifier<AdVideoListState> {
  final AdVideoService adVideoService;

  int _currentPage = 1;
  final int _limit = 20;

  AdVideoListNotifier(this.adVideoService) : super(AdVideoListState());

  Future<void> loadAdVideos({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      state = state.copyWith(isLoading: true, adVideoConfigs: [], hasMore: true);
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final resp = await adVideoService.getAdVideoList(
        page: _currentPage,
        limit: _limit,
      );

      final data = resp.data;
      if (data == null) throw Exception("Response data null");

      final newList = [...state.adVideoConfigs, ...data.list];

      final bool stillMore =
          newList.length < data.total && data.list.length == _limit;

      state = state.copyWith(
        adVideoConfigs: newList,
        hasMore: stillMore,
        error: null,
      );

      if (stillMore) {
        _currentPage++;
      }
    } catch (e) {
      debugPrint("load ad videos error: $e");
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void reset() {
    _currentPage = 1;
    state = AdVideoListState();
  }
}

final adVideoListProvider =
    StateNotifierProvider<AdVideoListNotifier, AdVideoListState>((ref) {
  final adVideoService = ref.watch(adVideoServiceProvider);
  return AdVideoListNotifier(adVideoService);
});

final adVideoCountProvider = Provider<int>((ref) {
  return ref.watch(adVideoListProvider).adVideoConfigs.length;
});

final adVideoPreloadServiceProvider = Provider<AdVideoPreloadService>((ref) {
  final videoService = ref.watch(videoServiceProvider);
  return AdVideoPreloadService(videoService);
});
