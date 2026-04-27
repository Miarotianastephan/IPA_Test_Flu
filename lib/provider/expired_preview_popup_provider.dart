import 'package:flutter_riverpod/flutter_riverpod.dart';

/// StateNotifier 管理每个页面每个视频是否已经弹过预览结束弹窗
class PreviewPopupTracker extends StateNotifier<Map<String, Map<String, bool>>> {
  PreviewPopupTracker() : super({});

  /// 返回指定页面和视频是否已经弹过
  bool isShown(String pageKey, String videoId) {
    return state[pageKey]?[videoId] == true;
  }

  /// 标记指定页面和视频已弹过
  void markShown(String pageKey, String videoId) {
    final pageMap = state[pageKey] ?? {};
    pageMap[videoId] = true;
    state = {...state, pageKey: pageMap};
  }

  /// 清除指定页面的视频标记
  void clear(String pageKey, String videoId) {
    final pageMap = {...?state[pageKey]};
    pageMap.remove(videoId);
    state = {...state, pageKey: pageMap};
  }

  /// 清除整个页面的记录
  void clearPage(String pageKey) {
    final newState = {...state};
    newState.remove(pageKey);
    state = newState;
  }

  /// 清除全部记录
  void clearAll() {
    state = {};
  }
}

/// Provider
final previewPopupTrackerProvider =
StateNotifierProvider<PreviewPopupTracker, Map<String, Map<String, bool>>>(
      (ref) => PreviewPopupTracker(),
);