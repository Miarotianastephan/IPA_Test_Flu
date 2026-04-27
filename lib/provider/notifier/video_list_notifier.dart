import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/page_response.dart';
import '../../models/video_info.dart';
import '../../models/video_list_state.dart';
import '../../repository/image_repository.dart';

/// 通用视频列表逻辑封装
abstract class BaseVideoListNotifier extends StateNotifier<VideoListState> {
  final Ref ref;

  /// 用户ID → 视频索引列表
  Map<String, List<int>> userVideoIndexMap = {};

  /// 视频ID → 索引
  Map<String, int> videoIndexMap = {};

  BaseVideoListNotifier(this.ref) : super(VideoListState());

  /// Override in feeds that intentionally keep a moving window in memory.
  int? get maxVideosInMemory => null;

  /// Override in feeds that should drop duplicate videos while merging pages.
  bool get dedupeByVideoId => false;

  /// Search/category lists may rely on the backend returning an empty page
  /// instead of accurate totals or limits, so keep the old behavior by default.
  bool get useSmartFinishedDetection => false;

  /// Append the next page in a few smaller chunks to reduce a single
  /// frame spike when the list length jumps during active scrolling.
  bool get supportsIncrementalWebAppend => false;

  int get incrementalWebAppendChunkSize => 6;

  /// 子类实现具体加载逻辑
  Future<PageResponse<VideoInfo>?> loadList({required int page});

  /// 通用拉取逻辑 (优化版 - Windowing for O(1))
  Future<void> fetch({bool refresh = false}) async {
    if (state.loading || (state.finished && !refresh)) return;
    try {
      final previousList = List<VideoInfo>.from(state.list);
      state = state.copyWith(loading: true);
      final page = refresh ? 1 : state.page;

      final pageResponse = await loadList(page: page);
      final newList = pageResponse?.list ?? <VideoInfo>[];
      final total = pageResponse?.total ?? 0;
      final pageSize = pageResponse?.limit ?? newList.length;

      List<VideoInfo> updatedVideos;
      int newOffset = state.offset;

      if (refresh) {
        updatedVideos = newList;
        newOffset = 0;
      } else {
        final maxRetainedVideos = maxVideosInMemory;
        if (maxRetainedVideos != null &&
            maxRetainedVideos > 0 &&
            state.list.length + newList.length > maxRetainedVideos) {
          final int keepCount = maxRetainedVideos - newList.length;
          final int removedCount = state.list.length - keepCount;

          updatedVideos = [...state.list.sublist(removedCount), ...newList];

          newOffset = state.offset + removedCount;
        } else {
          updatedVideos = List<VideoInfo>.from(state.list)..addAll(newList);
        }
      }

      if (dedupeByVideoId) {
        updatedVideos = _dedupeVideosById(updatedVideos);
      }

      _rebuildIndexMaps(updatedVideos, newOffset);

      if (!kIsWeb) {
        preLoadImage(newList);
      }

      final loadedCount = newOffset + updatedVideos.length;
      final reachedTotal = total > 0 && loadedCount >= total;
      final reachedShortPage =
          pageResponse != null && pageSize > 0 && newList.length < pageSize;
      final isFinished = useSmartFinishedDetection
          ? (newList.isEmpty || reachedTotal || reachedShortPage)
          : newList.isEmpty;
      final incrementalAppendItems = _extractIncrementalAppendItems(
        previousList: previousList,
        updatedVideos: updatedVideos,
        newOffset: newOffset,
      );

      if (_shouldUseIncrementalWebAppend(
        refresh: refresh,
        pageItems: incrementalAppendItems,
        newOffset: newOffset,
      )) {
        await _appendPageIncrementally(
          baseList: previousList,
          pageItems: incrementalAppendItems,
          page: page,
          total: total,
          isFinished: isFinished,
          offset: newOffset,
        );
        return;
      }

      state = state.copyWith(
        list: updatedVideos,
        page: page + 1,
        loading: false,
        finished: isFinished,
        total: total,
        offset: newOffset,
      );
    } catch (e, st) {
      debugPrint("加载视频失败: $e");
      debugPrintStack(stackTrace: st);
      state = state.copyWith(loading: false);
    }
  }

  bool _shouldUseIncrementalWebAppend({
    required bool refresh,
    required List<VideoInfo> pageItems,
    required int newOffset,
  }) {
    if (!supportsIncrementalWebAppend ||
        refresh ||
        pageItems.length <= incrementalWebAppendChunkSize ||
        state.list.isEmpty) {
      return false;
    }

    return newOffset == state.offset;
  }

  List<VideoInfo> _extractIncrementalAppendItems({
    required List<VideoInfo> previousList,
    required List<VideoInfo> updatedVideos,
    required int newOffset,
  }) {
    if (previousList.isEmpty ||
        newOffset != state.offset ||
        updatedVideos.length <= previousList.length) {
      return const <VideoInfo>[];
    }

    for (var i = 0; i < previousList.length; i++) {
      if (previousList[i].id != updatedVideos[i].id) {
        return const <VideoInfo>[];
      }
    }

    return List<VideoInfo>.from(updatedVideos.skip(previousList.length));
  }

  Future<void> _appendPageIncrementally({
    required List<VideoInfo> baseList,
    required List<VideoInfo> pageItems,
    required int page,
    required int total,
    required bool isFinished,
    required int offset,
  }) async {
    final chunkSize = math.max(1, incrementalWebAppendChunkSize);
    final growingList = List<VideoInfo>.from(baseList);

    await SchedulerBinding.instance.endOfFrame;

    for (int start = 0; start < pageItems.length; start += chunkSize) {
      final end = math.min(start + chunkSize, pageItems.length);
      final isLastChunk = end >= pageItems.length;
      growingList.addAll(pageItems.sublist(start, end));
      _rebuildIndexMaps(growingList, offset);

      state = state.copyWith(
        list: List<VideoInfo>.from(growingList),
        page: isLastChunk ? page + 1 : state.page,
        loading: !isLastChunk,
        finished: isLastChunk ? isFinished : state.finished,
        total: total,
        offset: offset,
      );

      if (!isLastChunk) {
        await SchedulerBinding.instance.endOfFrame;
      }
    }
  }

  void _rebuildIndexMaps(List<VideoInfo> videos, int offset) {
    userVideoIndexMap = {};
    videoIndexMap = {};

    for (int i = 0; i < videos.length; i++) {
      final v = videos[i];
      final virtualIndex = offset + i;
      userVideoIndexMap.putIfAbsent(v.userId, () => []).add(virtualIndex);
      videoIndexMap[v.id] = virtualIndex;
    }
  }

  List<VideoInfo> _dedupeVideosById(List<VideoInfo> videos) {
    final seen = <String>{};
    final deduped = <VideoInfo>[];

    for (final video in videos) {
      if (seen.add(video.id)) {
        deduped.add(video);
      }
    }

    return deduped;
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
  void updateFollowStatus(String userId, bool isFollow) {
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
  void incrementCommentCount(String videoId) {
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
      } else {
        finalVideos = videosToAdd;
        newOffset = state.offset + currentListLength;
      }
    }

    if (dedupeByVideoId) {
      finalVideos = _dedupeVideosById(finalVideos);
    }

    _rebuildIndexMaps(finalVideos, newOffset);

    state = state.copyWith(list: finalVideos, offset: newOffset);
  }

  void preLoadImage(List<VideoInfo> videos) {
    final imageRepo = ref.read(imageRepositoryProvider);
    const warmCoverCount = 8;

    for (int index = 0; index < videos.length; index++) {
      final video = videos[index];
      final url = video.cover;
      final userAvatarUrl = video.user.avatar;
      if (url.isNotEmpty) {
        if (index < warmCoverCount) {
          imageRepo.enqueueWarmBytes(url);
        } else {
          imageRepo.enqueueDownload(url);
        }
      }

      if (userAvatarUrl != null && userAvatarUrl.isNotEmpty) {
        imageRepo.enqueueDownload(userAvatarUrl);
      }
    }
  }
}
