import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/api/services/video_service.dart';
import 'package:live_app/models/page_params.dart';
import 'package:live_app/models/video_comment.dart';

import 'api_provider.dart';

class RepliesState {
  final List<VideoComment> list;
  final int page;
  final bool finished;
  final bool loading;

  RepliesState({
    this.list = const [],
    this.page = 0,
    this.finished = false,
    this.loading = false,
  });

  RepliesState copyWith({
    List<VideoComment>? list,
    int? page,
    bool? finished,
    bool? loading,
  }) {
    return RepliesState(
      list: list ?? this.list,
      page: page ?? this.page,
      finished: finished ?? this.finished,
      loading: loading ?? this.loading,
    );
  }
}

class CommentsState {
  final List<VideoComment> comments;
  final Map<int, RepliesState> repliesMap;
  final int page;
  final bool finished;
  final bool loading;
  final bool loadedOnce;

  CommentsState({
    this.comments = const [],
    this.repliesMap = const {},
    this.page = 1,
    this.finished = false,
    this.loading = false,
    this.loadedOnce = false,
  });

  CommentsState copyWith({
    List<VideoComment>? comments,
    Map<int, RepliesState>? repliesMap,
    int? page,
    bool? finished,
    bool? loading,
    bool? loadedOnce,
  }) {
    return CommentsState(
      comments: comments ?? this.comments,
      repliesMap: repliesMap ?? this.repliesMap,
      page: page ?? this.page,
      finished: finished ?? this.finished,
      loading: loading ?? this.loading,
      loadedOnce: loadedOnce ?? this.loadedOnce,
    );
  }
}

class CommentsNotifier extends StateNotifier<CommentsState> {
  final Ref ref;
  final String videoId;
  late final VideoService videoService;

  CommentsNotifier(this.ref, this.videoId) : super(CommentsState()) {
    videoService = ref.read(videoServiceProvider);
  }

  Future<void> fetch({bool refresh = false}) async {
    if (state.loading) return;
    if (!refresh && state.finished) return;

    final nextPage = refresh ? 1 : state.page + 1;
    state = state.copyWith(loading: true);

    try {
      final response = await videoService.videoRootCommentList(
        PageParams(page: nextPage),
        videoId,
      );

      final newList = (response.data?.list ?? [])
          .map((e) => VideoComment.fromJson(e.toJson()))
          .where((c) => c.parentId == 0)
          .toList();

      for (var i = 0; i < newList.length; i++) {
        final comment = newList[i];
        try {
          final childResponse = await videoService.videoChildCommentList(
            PageParams(page: 1),
            comment.id,
          );

          newList[i] = VideoComment(
            id: comment.id,
            videoId: comment.videoId,
            userId: comment.userId,
            content: comment.content,
            parentId: comment.parentId,
            likeCount: comment.likeCount,
            createdAt: comment.createdAt,
            childCount: childResponse.data?.total ?? comment.childCount,
            isLike: comment.isLike,
            commentUser: comment.commentUser,
            commentToUser: comment.commentToUser,
            vCommentLikes: comment.vCommentLikes,
          );
        } catch (e) {
          debugPrint(
            'Error fetching child count for comment ${comment.id}: $e',
          );
        }
      }

      final total = response.data?.total ?? 0;
      final updatedList = refresh ? newList : [...state.comments, ...newList];

      state = state.copyWith(
        comments: updatedList,
        page: nextPage,
        finished: updatedList.length >= total,
        loading: false,
        loadedOnce: true,
      );
    } catch (e) {
      debugPrint('Error fetching comments: $e');
      state = state.copyWith(loading: false, loadedOnce: true);
    }
  }

  Future<void> fetchReplies(int parentId, {bool refresh = false}) async {
    final repliesState = state.repliesMap[parentId] ?? RepliesState();

    if (repliesState.loading) return;
    if (!refresh && repliesState.finished) return;

    final nextPage = refresh ? 1 : repliesState.page + 1;
    final updatedRepliesMap = {
      ...state.repliesMap,
      parentId: repliesState.copyWith(loading: true),
    };
    state = state.copyWith(repliesMap: updatedRepliesMap);

    try {
      debugPrint("Fetching replies for parentId: $parentId, page: $nextPage");
      final response = await videoService.videoChildCommentList(
        PageParams(page: nextPage),
        parentId,
      );

      final newReplies = (response.data?.list ?? [])
          .map((e) => VideoComment.fromJson(e.toJson()))
          .toList();

      final total = response.data?.total ?? 0;
      final updatedList = refresh
          ? newReplies
          : [...repliesState.list, ...newReplies];

      updatedRepliesMap[parentId] = repliesState.copyWith(
        list: updatedList,
        page: nextPage,
        finished: updatedList.length >= total || newReplies.isEmpty,
        loading: false,
      );

      state = state.copyWith(repliesMap: updatedRepliesMap);
    } catch (e) {
      debugPrint('Error fetching replies: $e');
      updatedRepliesMap[parentId] = repliesState.copyWith(loading: false);
      state = state.copyWith(repliesMap: updatedRepliesMap);
    }
  }

  Future<void> addComment(VideoComment newComment) async {
    final parentId = newComment.parentId;

    if (parentId == null || parentId == 0) {
      final updatedComments = [newComment, ...state.comments];
      state = state.copyWith(comments: updatedComments);
    } else {
      final repliesState = state.repliesMap[parentId] ?? RepliesState();

      final updatedReplies = [newComment, ...repliesState.list];
      final Map<int, RepliesState> updatedRepliesMap = {
        ...state.repliesMap,
        parentId: repliesState.copyWith(list: updatedReplies),
      };

      final updatedComments = state.comments.map((comment) {
        if (comment.id == parentId) {
          return VideoComment(
            id: comment.id,
            videoId: comment.videoId,
            userId: comment.userId,
            content: comment.content,
            parentId: comment.parentId,
            likeCount: comment.likeCount,
            createdAt: comment.createdAt,
            childCount: comment.childCount + 1,
            isLike: comment.isLike,
            commentUser: comment.commentUser,
            commentToUser: comment.commentToUser,
            vCommentLikes: comment.vCommentLikes,
          );
        }
        return comment;
      }).toList();

      state = state.copyWith(
        comments: updatedComments,
        repliesMap: updatedRepliesMap,
      );
    }
  }

  Future<void> refreshAfterComment({int? parentId}) async {
    if (parentId != null && parentId != 0) {
      await fetchReplies(parentId, refresh: true);

      try {
        final childResponse = await videoService.videoChildCommentList(
          PageParams(page: 1),
          parentId,
        );

        final updatedComments = state.comments.map((comment) {
          if (comment.id == parentId) {
            return VideoComment(
              id: comment.id,
              videoId: comment.videoId,
              userId: comment.userId,
              content: comment.content,
              parentId: comment.parentId,
              likeCount: comment.likeCount,
              createdAt: comment.createdAt,
              childCount: childResponse.data?.total ?? comment.childCount,
              isLike: comment.isLike,
              commentUser: comment.commentUser,
              commentToUser: comment.commentToUser,
              vCommentLikes: comment.vCommentLikes,
            );
          }
          return comment;
        }).toList();

        state = state.copyWith(comments: updatedComments);
      } catch (e) {
        debugPrint('Error updating parent child count: $e');
      }
    } else {
      await fetch(refresh: true);
    }
  }
}

final commentsProvider =
    StateNotifierProvider.family<CommentsNotifier, CommentsState, String>((
      ref,
      videoId,
    ) {
      return CommentsNotifier(ref, videoId);
    });
