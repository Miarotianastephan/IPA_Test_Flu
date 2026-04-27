import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/base_list_state.dart';
import '../../models/forum_post.dart';
import '../../models/page_response.dart';

/// 通用帖子列表逻辑
abstract class BasePostListNotifier
    extends StateNotifier<BaseListState<ForumPost>> {
  final Ref ref;

  BasePostListNotifier(this.ref) : super(BaseListState<ForumPost>());

  /// Append the next page in smaller chunks on web to reduce frame spikes.
  bool get supportsIncrementalWebAppend => false;

  int get incrementalWebAppendChunkSize => 4;

  /// 子类负责实现：加载帖子接口
  Future<PageResponse<ForumPost>?> loadList({
    required int page,
    int limit = 20,
  });

  /// 拉取/加载更多
  Future<void> fetch({bool refresh = false, int limit = 20}) async {
    if (state.loading || (state.finished && !refresh)) return;

    try {
      final previousList = List<ForumPost>.from(state.list);
      state = state.copyWith(loading: true);

      final page = refresh ? 1 : state.page;
      final response = await loadList(page: page, limit: limit);

      final newList = response?.list ?? <ForumPost>[];
      final total = response?.total ?? 0;
      final isFinished = newList.isEmpty;

      if (_shouldUseIncrementalWebAppend(
        refresh: refresh,
        previousList: previousList,
        pageItems: newList,
      )) {
        await _appendPageIncrementally(
          baseList: previousList,
          pageItems: newList,
          page: page,
          total: total,
          isFinished: isFinished,
        );
        return;
      }

      final merged = refresh ? newList : [...previousList, ...newList];

      state = state.copyWith(
        list: merged,
        page: page + 1,
        loading: false,
        finished: isFinished,
        total: total,
      );
    } catch (e, st) {
      debugPrint('Post fetch error: $e\n$st');
      state = state.copyWith(loading: false);
    }
  }

  bool _shouldUseIncrementalWebAppend({
    required bool refresh,
    required List<ForumPost> previousList,
    required List<ForumPost> pageItems,
  }) {
    if (!kIsWeb ||
        !supportsIncrementalWebAppend ||
        refresh ||
        previousList.isEmpty ||
        pageItems.length <= incrementalWebAppendChunkSize) {
      return false;
    }

    return true;
  }

  Future<void> _appendPageIncrementally({
    required List<ForumPost> baseList,
    required List<ForumPost> pageItems,
    required int page,
    required int total,
    required bool isFinished,
  }) async {
    final chunkSize = math.max(1, incrementalWebAppendChunkSize);
    final growingList = List<ForumPost>.from(baseList);

    await SchedulerBinding.instance.endOfFrame;

    for (int start = 0; start < pageItems.length; start += chunkSize) {
      final end = math.min(start + chunkSize, pageItems.length);
      final isLastChunk = end >= pageItems.length;
      growingList.addAll(pageItems.sublist(start, end));

      state = state.copyWith(
        list: List<ForumPost>.from(growingList),
        page: isLastChunk ? page + 1 : state.page,
        loading: !isLastChunk,
        finished: isLastChunk ? isFinished : state.finished,
        total: total,
      );

      if (!isLastChunk) {
        await SchedulerBinding.instance.endOfFrame;
      }
    }
  }
}
