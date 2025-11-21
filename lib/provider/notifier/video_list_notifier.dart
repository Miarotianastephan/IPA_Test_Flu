import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/page_response.dart';
import '../../models/video_info.dart';
import '../../models/video_list_state.dart';

/// 通用视频列表逻辑封装
abstract class BaseVideoListNotifier extends StateNotifier<VideoListState> {
  final Ref ref;

  /// 用户ID → 视频索引列表
  Map<int, List<int>> userVideoIndexMap = {};

  /// 视频ID → 索引
  Map<int, int> videoIndexMap = {};

  BaseVideoListNotifier(this.ref) : super(VideoListState());

  /// 子类实现具体加载逻辑
  Future<PageResponse<VideoInfo>?> loadList({required int page});

  /// 通用拉取逻辑
  Future<void> fetch({bool refresh = false}) async {
    if (state.loading || (state.finished && !refresh)) return;
    try {
      state = state.copyWith(loading: true);
      final page = refresh ? 1 : state.page;

      final pageResponse = await loadList(page: page);
      final newList = pageResponse?.list ?? <VideoInfo>[];
      final total = pageResponse?.total ?? 0;

      final updatedVideos = refresh ? newList : [...state.list, ...newList];

      // 更新索引映射
      _updateIndexMaps(updatedVideos, newList, refresh);

      state = state.copyWith(
        list: updatedVideos,
        page: page + 1,
        loading: false,
        finished: newList.isEmpty,
        total: total,
      );
    } catch (e, st) {
      debugPrint("加载视频失败: $e");
      debugPrintStack(stackTrace: st);
      state = state.copyWith(loading: false);
    }
  }

  /// 构建或增量更新索引表
  void _updateIndexMaps(
    List<VideoInfo> updatedVideos,
    List<VideoInfo> newList,
    bool refresh,
  ) {
    if (refresh) {
      userVideoIndexMap = {};
      videoIndexMap = {};
      for (int i = 0; i < updatedVideos.length; i++) {
        final v = updatedVideos[i];
        userVideoIndexMap.putIfAbsent(v.userId, () => []).add(i);
        videoIndexMap[v.id] = i;
      }
    } else {
      final startIndex = state.list.length;
      for (int i = 0; i < newList.length; i++) {
        final v = newList[i];
        userVideoIndexMap.putIfAbsent(v.userId, () => []).add(startIndex + i);
        videoIndexMap[v.id] = startIndex + i;
      }
    }
  }

  /// 更新单个视频
  void updateVideo(VideoInfo updatedVideo) {
    final index = videoIndexMap[updatedVideo.id];
    if (index == null) return;
    final updatedList = [...state.list];
    updatedList[index] = updatedVideo;
    state = state.copyWith(list: updatedList);
  }

  /// 更新用户所有视频的关注状态
  void updateFollowStatus(int userId, bool isFollow) {
    final indices = userVideoIndexMap[userId];
    if (indices == null) return;
    final updatedList = [...state.list];
    for (final i in indices) {
      updatedList[i] = updatedList[i].copyWith(isFollow: isFollow);
    }
    state = state.copyWith(list: updatedList);
  }

  /// 评论数 +1
  void incrementCommentCount(int videoId) {
    final index = videoIndexMap[videoId];
    if (index == null) return;
    final updatedList = [...state.list];
    final video = updatedList[index];
    updatedList[index] = video.copyWith(commentCount: video.commentCount + 1);
    state = state.copyWith(list: updatedList);
  }
}
