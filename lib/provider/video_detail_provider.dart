import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/page_params.dart';

import '../models/video_info.dart';
import 'api_provider.dart';

class VideoDetailState {
  final VideoInfo? video;
  final bool loading;
  final String? error;
  final List<VideoInfo> recommendedVideos;
  final bool recommendedVideosLoading; // 明确类型为 bool

  VideoDetailState({
    this.video,
    this.loading = false,
    this.error,
    this.recommendedVideos = const [],
    this.recommendedVideosLoading = false,
  });

  VideoDetailState copyWith({
    VideoInfo? video,
    bool? loading,
    String? error,
    List<VideoInfo>? recommendedVideos,
    bool? recommendedVideosLoading,
  }) {
    return VideoDetailState(
      video: video ?? this.video,
      loading: loading ?? this.loading,
      error: error ?? this.error,
      recommendedVideos: recommendedVideos ?? this.recommendedVideos,
      recommendedVideosLoading:
          recommendedVideosLoading ?? this.recommendedVideosLoading,
    );
  }
}

class VideoDetailNotifier extends StateNotifier<VideoDetailState> {
  final Ref ref;

  VideoDetailNotifier(this.ref) : super(VideoDetailState());

  /// 加载视频详情
  Future<void> loadVideoDetail(int videoId) async {
    state = state.copyWith(loading: true, error: null);

    try {
      final videoService = ref.read(videoServiceProvider);
      final res = await videoService.detail(videoId);
      final video = res.data;

      // 先只更新视频信息
      state = state.copyWith(video: video);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(loading: false);
    }
  }

  /// 单独加载推荐视频
  Future<void> getRecommendedVideos(int videoId) async {
    // 如果已经加载过推荐视频，就不再重复请求
    if (state.recommendedVideos.isNotEmpty) {
      debugPrint('推荐视频已加载，跳过请求');
      return;
    }

    // 如果正在加载中，也不再重复请求
    if (state.recommendedVideosLoading) {
      debugPrint('推荐视频正在加载中，跳过请求');
      return;
    }

    try {
      // 请求前设置加载状态
      state = state.copyWith(recommendedVideosLoading: true);

      final videoService = ref.read(videoServiceProvider);
      final recRes = await videoService.relevanceRecommend(
        PageParams(page: 1, limit: 50),
        videoId,
      );
      final recommendedVideos = recRes.data?.list ?? [];
      debugPrint('加载到 ${recommendedVideos.length} 个推荐视频');
      // 更新推荐视频列表，同时结束加载状态
      state = state.copyWith(
        recommendedVideos: recommendedVideos,
        recommendedVideosLoading: false,
      );
    } catch (e) {
      debugPrint('加载推荐视频失败: $e');
      // 出错也结束加载状态
      state = state.copyWith(recommendedVideosLoading: false);
    }
  }

  /// 收藏 / 取消收藏
  Future<void> toggleFavorite() async {
    final video = state.video;
    if (video == null) return;

    final videoService = ref.read(videoServiceProvider);
    final newValue = !video.isFavorite;

    try {
      if (newValue) {
        await videoService.favoriteVideo(video.id);
      } else {
        await videoService.unFavoriteVideo(video.id);
      }

      state = state.copyWith(
        video: video.copyWith(
          isFavorite: newValue,
          favoriteCount: newValue
              ? video.favoriteCount + 1
              : (video.favoriteCount > 0 ? video.favoriteCount - 1 : 0),
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// 点赞 / 取消点赞
  Future<void> toggleLike() async {
    final video = state.video;
    if (video == null) return;

    final videoService = ref.read(videoServiceProvider);
    final newValue = !video.isLike;

    try {
      if (newValue) {
        await videoService.likeVideo(video.id);
      } else {
        await videoService.unlikeVideo(video.id);
      }

      state = state.copyWith(
        video: video.copyWith(
          isLike: newValue,
          likeCount: newValue
              ? video.likeCount + 1
              : (video.likeCount > 0 ? video.likeCount - 1 : 0),
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// 关注 / 取关作者
  Future<void> toggleFollow() async {
    final video = state.video;
    // 没有视频或没有用户信息的话就不用处理
    if (video == null) return;

    final user = video.user;
    final oldVideo = video;
    final newValue = !video.isFollow;

    // 本地立即更新状态（乐观更新）
    state = state.copyWith(
      video: video.copyWith(
        isFollow: newValue,
        // 如果你希望顺便更新粉丝数，可以加上这一段：
        user: user.copyWith(
          fansCount: newValue
              ? (user.fansCount ?? 0) + 1
              : ((user.fansCount ?? 0) > 0 ? (user.fansCount ?? 0) - 1 : 0),
        ),
      ),
    );

    try {
      final userService = ref.read(userServiceProvider);

      if (newValue) {
        await userService.follow(user.id);
      } else {
        await userService.unfollow(user.id);
      }
    } catch (e) {
      // 网络失败回滚
      debugPrint('切换关注失败: $e');
      state = state.copyWith(video: oldVideo);
    }
  }

  /// 分享视频
  Future<void> shareVideo() async {
    final video = state.video;
    if (video == null) return;

    final videoService = ref.read(videoServiceProvider);

    try {
      await videoService.shareVideo(video.id);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// 记录已看
  Future<void> markSeen() async {
    final video = state.video;
    if (video == null) return;

    final videoService = ref.read(videoServiceProvider);

    try {
      await videoService.seen(video.id);
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}

final videoDetailProvider =
    StateNotifierProvider.family<VideoDetailNotifier, VideoDetailState, int>((
      ref,
      videoId,
    ) {
      return VideoDetailNotifier(ref);
    });
