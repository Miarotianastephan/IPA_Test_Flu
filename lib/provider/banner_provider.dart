import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/api/services/banner_service.dart';
import 'package:live_app/models/banner.dart';
import 'package:live_app/provider/api_provider.dart';

class BannerListState {
  final List<BannerModel> banners;
  final bool isLoading;
  final String? error;
  final bool hasMore; // pagination support

  BannerListState({
    this.banners = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
  });

  BannerListState copyWith({
    List<BannerModel>? banners,
    bool? isLoading,
    String? error,
    bool? hasMore,
  }) {
    return BannerListState(
      banners: banners ?? this.banners,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class BannerListNotifier extends StateNotifier<BannerListState> {
  final BannerService bannerService;

  int _currentPage = 1;
  final int _limit = 20;

  BannerListNotifier(this.bannerService) : super(BannerListState());

  Future<void> loadBanners({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      state = state.copyWith(isLoading: true, banners: [], hasMore: true);
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final resp = await bannerService.getBanner(
        page: _currentPage,
        limit: _limit,
      );

      final data = resp.data;
      if (data == null) throw Exception("Response data null");

      final newList = [...state.banners, ...data.list];

      final bool stillMore =
          newList.length < data.total && data.list.length == _limit;

      state = state.copyWith(
        banners: newList,
        hasMore: stillMore,
        error: null,
      );

      if (stillMore) {
        _currentPage++;
      }
    } catch (e) {
      debugPrint("load banners error: $e");
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void reset() {
    _currentPage = 1;
    state = BannerListState();
  }
}

final bannerListProvider =
    StateNotifierProvider<BannerListNotifier, BannerListState>((ref) {
  final client = ref.watch(apiClientProvider); 
  return BannerListNotifier(BannerService(client));
});

final bannerCountProvider = Provider<int>((ref) {
  return ref.watch(bannerListProvider).banners.length;
});
