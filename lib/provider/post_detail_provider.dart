// 帖子详情 Provider（使用 StateNotifier 与状态管理）
// ----------------------------------------------

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/forum_post.dart';
import 'api_provider.dart';

/// 帖子详情状态
class PostDetailState {
  final ForumPost? post;
  final bool loading;
  final String? error;

  PostDetailState({this.post, this.loading = false, this.error});

  PostDetailState copyWith({ForumPost? post, bool? loading, String? error}) {
    return PostDetailState(
      post: post ?? this.post,
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }
}

/// 帖子详情 StateNotifier
class PostDetailNotifier extends StateNotifier<PostDetailState> {
  final Ref ref;

  PostDetailNotifier(this.ref) : super(PostDetailState());

  /// 加载帖子详情
  Future<void> loadPostDetail(int postId) async {
    state = state.copyWith(loading: true, error: null);

    try {
      final service = ref.read(forumServiceProvider);

      // 记录浏览
      await service.view(postId);

      final resp = await service.detail(postId);

      if (resp.code == 1 && resp.data != null) {
        state = state.copyWith(post: resp.data);
      } else {
        state = state.copyWith(error: resp.msg);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(loading: false);
    }
  }

  /// 点赞 / 取消点赞
  Future<void> toggleLike() async {
    final post = state.post;
    if (post == null) return;

    final service = ref.read(forumServiceProvider);
    final newValue = !post.isLiked;

    // If liking, cancel downvote
    if (newValue && (post.isDownvoted ?? false)) {
      try {
        await service.voteCancel(post.id);
      } catch (_) {}
    }

    try {
      if (newValue) {
        await service.vote(post.id, "up");
      } else {
        await service.voteCancel(post.id);
      }

      state = state.copyWith(
        post: post.copyWith(
          isLiked: newValue,
          likeCount: newValue
              ? post.likeCount + 1
              : (post.likeCount > 0 ? post.likeCount - 1 : 0),
          isDownvoted: newValue ? false : post.isDownvoted,
          dislikeCount: newValue && (post.isDownvoted ?? false)
              ? (post.dislikeCount > 0 ? post.dislikeCount - 1 : 0)
              : post.dislikeCount,
        ),
      );
    } catch (_) {}
  }

  /// 收藏 / 取消收藏
  Future<void> toggleFavorite() async {
    final post = state.post;
    if (post == null) return;

    final service = ref.read(forumServiceProvider);
    final newValue = !post.isFavorited;

    try {
      await service.favorite(post.id);

      state = state.copyWith(
        post: post.copyWith(
          isFavorited: newValue,
          favoriteCount: newValue
              ? post.favoriteCount + 1
              : (post.favoriteCount > 0 ? post.favoriteCount - 1 : 0),
        ),
      );
    } catch (_) {}
  }

  /// 点踩 / 取消点踩
  Future<void> toggleDownvote() async {
    final post = state.post;
    if (post == null) return;

    final service = ref.read(forumServiceProvider);
    final newValue = !(post.isDownvoted ?? false);

    try {
      if (newValue) {
        // If downvoting, cancel like
        if (post.isLiked) {
          try {
            await service.voteCancel(post.id);
          } catch (_) {}
        }
        await service.vote(post.id, "down");
      } else {
        await service.voteCancel(post.id);
      }

      state = state.copyWith(
        post: post.copyWith(
          isDownvoted: newValue,
          dislikeCount: newValue
              ? post.dislikeCount + 1
              : (post.dislikeCount > 0 ? post.dislikeCount - 1 : 0),
          isLiked: newValue ? false : post.isLiked,
          likeCount: newValue && post.isLiked
              ? (post.likeCount > 0 ? post.likeCount - 1 : 0)
              : post.likeCount,
        ),
      );
    } catch (_) {}
  }

  /// 关注 / 取消关注作者
  Future<void> toggleFollow() async {
    final post = state.post;
    if (post == null || post.user == null) return;

    final user = post.user!;
    final newValue = !user.isFollowed;

    // 本地立即更新状态
    state = state.copyWith(
      post: post.copyWith(user: user.copyWith(isFollowed: newValue)),
    );

    try {
      final userService = ref.read(userServiceProvider);

      if (newValue) {
        await userService.follow(user.id);
      } else {
        await userService.unfollow(user.id);
      }
    } catch (_) {
      // 网络失败回滚
      state = state.copyWith(post: post);
    }
  }

  void increaseCommentCount() {
    final post = state.post;
    if (post == null) return;

    state = state.copyWith(
      post: post.copyWith(commentCount: post.commentCount + 1),
    );
  }
}

/// Provider
final postDetailProvider =
    StateNotifierProvider.family<PostDetailNotifier, PostDetailState, int>((
      ref,
      postId,
    ) {
      return PostDetailNotifier(ref);
    });
