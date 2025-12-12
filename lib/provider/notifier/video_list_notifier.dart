import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/base_list_state.dart';
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

  /// 通用拉取逻辑 (优化版 - Windowing for O(1))
  Future<void> fetch({bool refresh = false}) async {
    if (state.loading || (state.finished && !refresh)) return;
    try {
      state = state.copyWith(loading: true);
      final page = refresh ? 1 : state.page;

      final pageResponse = await loadList(page: page);
      final newList = pageResponse?.list ?? <VideoInfo>[];
      final total = pageResponse?.total ?? 0;

      List<VideoInfo> updatedVideos;
      int newOffset = state.offset;

      if (refresh) {
        updatedVideos = newList;
        newOffset = 0;
        userVideoIndexMap = {};
        videoIndexMap = {};
        _buildIndexMaps(updatedVideos, 0);
      } else {
        if (state.list.length + newList.length >
            BaseListState.maxVideosInMemory) {
          final int keepCount =
              BaseListState.maxVideosInMemory - newList.length;
          final int removedCount = state.list.length - keepCount;

          updatedVideos = [...state.list.sublist(removedCount), ...newList];

          newOffset = state.offset + removedCount;

          _cleanIndexMaps(removedCount);

          _buildIndexMaps(newList, keepCount);
        } else {
          updatedVideos = List<VideoInfo>.from(state.list)..addAll(newList);

          _buildIndexMaps(newList, state.list.length);
        }
      }

      state = state.copyWith(
        list: updatedVideos,
        page: page + 1,
        loading: false,
        finished: newList.isEmpty,
        total: total,
        offset: newOffset,
      );
    } catch (e, st) {
      debugPrint("加载视频失败: $e");
      debugPrintStack(stackTrace: st);
      state = state.copyWith(loading: false);
    }
  }

  void _buildIndexMaps(List<VideoInfo> newVideos, int startPhysicalIndex) {
    for (int i = 0; i < newVideos.length; i++) {
      final v = newVideos[i];
      final virtualIndex = startPhysicalIndex + i + state.offset;

      userVideoIndexMap.putIfAbsent(v.userId, () => []).add(virtualIndex);
      videoIndexMap[v.id] = virtualIndex;
    }
  }

  void _cleanIndexMaps(int removedCount) {
    final virtualThreshold = state.offset + removedCount;

    final videosToRemove = videoIndexMap.entries
        .where((e) => e.value < virtualThreshold)
        .map((e) => e.key)
        .toList();

    for (final videoId in videosToRemove) {
      videoIndexMap.remove(videoId);
    }

    final usersToUpdate = <int>[];
    for (final entry in userVideoIndexMap.entries) {
      final updatedIndices = entry.value
          .where((idx) => idx >= virtualThreshold)
          .toList();

      if (updatedIndices.isEmpty) {
        usersToUpdate.add(entry.key);
      } else {
        userVideoIndexMap[entry.key] = updatedIndices;
      }
    }

    for (final userId in usersToUpdate) {
      userVideoIndexMap.remove(userId);
    }
  }

  /// 更新单个视频 - O(1)
  void updateVideo(VideoInfo updatedVideo) {
    final virtualIndex = videoIndexMap[updatedVideo.id];
    if (virtualIndex == null) return;

    final physicalIndex = virtualIndex - state.offset;

    if (physicalIndex < 0 || physicalIndex >= state.list.length) return;

    final updatedList = [...state.list];
    updatedList[physicalIndex] = updatedVideo;
    state = state.copyWith(list: updatedList);
  }

  /// 更新用户所有视频的关注状态 - O(k) where k = users videos
  void updateFollowStatus(int userId, bool isFollow) {
    final virtualIndices = userVideoIndexMap[userId];
    if (virtualIndices == null) return;

    final updatedList = [...state.list];
    bool hasChanges = false;

    for (final virtualIndex in virtualIndices) {
      final physicalIndex = virtualIndex - state.offset;

      if (physicalIndex >= 0 && physicalIndex < state.list.length) {
        updatedList[physicalIndex] = updatedList[physicalIndex].copyWith(
          isFollow: isFollow,
        );
        hasChanges = true;
      }
    }

    if (hasChanges) {
      state = state.copyWith(list: updatedList);
    }
  }

  /// 评论数 +1 - O(1)
  void incrementCommentCount(int videoId) {
    final virtualIndex = videoIndexMap[videoId];
    if (virtualIndex == null) return;

    final physicalIndex = virtualIndex - state.offset;

    if (physicalIndex < 0 || physicalIndex >= state.list.length) return;

    final updatedList = [...state.list];
    final video = updatedList[physicalIndex];
    updatedList[physicalIndex] = video.copyWith(
      commentCount: video.commentCount + 1,
    );
    state = state.copyWith(list: updatedList);
  }

  void recycleVideos() {
    if (state.list.isEmpty) return;

    final currentListLength = state.list.length;
    final int videosToRecycle;

    if (currentListLength <= 50) {
      videosToRecycle = currentListLength;
    } else {
      videosToRecycle = (currentListLength * 0.75).ceil();
    }

    final videosToAdd = state.list.sublist(0, videosToRecycle);

    List<VideoInfo> finalVideos;
    int newOffset = state.offset;

    if (currentListLength <= 50) {
      finalVideos = [...state.list, ...videosToAdd];

      _buildIndexMaps(videosToAdd, state.list.length);
    } else {
      final maxToKeep = 50;
      final int keepFromCurrent = maxToKeep - videosToRecycle;

      if (keepFromCurrent > 0) {
        final videosToKeep = state.list.sublist(
          currentListLength - keepFromCurrent,
        );
        finalVideos = [...videosToKeep, ...videosToAdd];

        final removedCount = currentListLength - keepFromCurrent;
        newOffset = state.offset + removedCount;

        _cleanIndexMaps(removedCount);
      } else {
        finalVideos = videosToAdd;
        newOffset = state.offset + currentListLength;

        videoIndexMap.clear();
        userVideoIndexMap.clear();
      }

      final startIndex = keepFromCurrent > 0 ? keepFromCurrent : 0;
      _buildIndexMaps(videosToAdd, startIndex);
    }

    state = state.copyWith(list: finalVideos, offset: newOffset);
  }
}
