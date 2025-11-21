import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/services/forum_service.dart';
import '../models/forum_comment.dart';
import '../models/page_params.dart';
import 'api_provider.dart';

/// 评论列表状态
class ForumCommentsState {
  final List<ForumComment> comments;
  final int page;
  final bool loading;
  final bool finished;
  final bool firstLoaded;
  final String? error;

  const ForumCommentsState({
    this.comments = const [],
    this.page = 1,
    this.loading = false,
    this.finished = false,
    this.firstLoaded = false,
    this.error,
  });

  ForumCommentsState copyWith({
    List<ForumComment>? comments,
    int? page,
    bool? loading,
    bool? finished,
    bool? firstLoaded,
    String? error,
  }) {
    return ForumCommentsState(
      comments: comments ?? this.comments,
      page: page ?? this.page,
      loading: loading ?? this.loading,
      finished: finished ?? this.finished,
      firstLoaded: firstLoaded ?? this.firstLoaded,
      error: error,
    );
  }
}

/// 评论列表 Notifier（按 postId 维度）
class ForumCommentsNotifier extends StateNotifier<ForumCommentsState> {
  final ForumService forumService;
  final int postId;

  ForumCommentsNotifier(this.forumService, this.postId)
      : super(const ForumCommentsState());



  /// 下拉刷新
  Future<void> refresh() => _loadData(refresh: true);

  /// 上拉加载
  Future<void> loadMore() => _loadData(refresh: false);

  Future<void> _loadData({required bool refresh}) async {
    if (state.loading) return;
    if (!refresh && state.finished) return;

    state = state.copyWith(loading: true, error: null);

    try {
      final nextPage = refresh ? 1 : state.page + 1;

      final resp = await forumService.comments(
        PageParams(page: nextPage),
        postId,
      );

      final newList = (resp.data?.list ?? [])
          .map((e) => ForumComment.fromJson(e.toJson()))
          .toList();

      final merged = refresh ? newList : [...state.comments, ...newList];

      bool finished = false;
      if (resp.data?.total != null && merged.length >= resp.data!.total) {
        finished = true;
      }

      state = state.copyWith(
        comments: merged,
        page: nextPage,
        finished: finished,
        firstLoaded: true,
        loading: false,
      );
    } catch (e) {
      debugPrint("加载评论失败: $e");
      state = state.copyWith(
        loading: false,
        firstLoaded: true,
        error: e.toString(),
      );
    }
  }

  ///  评论成功后自动 append，不重新加载
  void addComment(ForumComment? comment) {
    if (comment == null){
      return;
    }
    state = state.copyWith(
      comments: [...state.comments, comment],
      finished: false,
    );
  }
}



/// Provider.family：按帖子 postId 区分
final forumCommentsProvider = StateNotifierProvider.family<
    ForumCommentsNotifier, ForumCommentsState, int>((ref, postId) {
  final service = ref.read(forumServiceProvider);
  return ForumCommentsNotifier(service, postId);
});