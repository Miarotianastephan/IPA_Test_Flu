import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:live_app/models/ad.dart';
import 'package:live_app/widgets/ad_banner_carousel.dart';
import 'package:live_app/widgets/video/recommend_item.dart';
import 'package:live_app/widgets/video/user_info_row.dart';

import '../../models/video_info.dart';
import '../../provider/video_detail_provider.dart';
import 'video_action_row.dart';
import 'video_info_row.dart';
import 'video_tag_category_wrap.dart';

class VideoDescriptionSection extends ConsumerStatefulWidget {
  final VideoInfo videoInfo;
  final List<Ad> ads;

  // 回调参数
  final Future<void> Function(bool)? onFollowPressed;
  final Future<void> Function(bool)? onLike;
  final Future<void> Function(bool)? onFavorite;
  final VoidCallback? onShare;
  final void Function(VideoInfo)? onRecommendedVideoTap;

  const VideoDescriptionSection({
    super.key,
    required this.videoInfo,
    this.ads = const [],
    this.onFollowPressed,
    this.onLike,
    this.onFavorite,
    this.onShare,
    this.onRecommendedVideoTap,
  });

  @override
  ConsumerState<VideoDescriptionSection> createState() =>
      _VideoDescriptionSectionState();
}

class _VideoDescriptionSectionState
    extends ConsumerState<VideoDescriptionSection> {
  bool _expanded = false; // 控制视频简介展开/收起

  @override
  void initState() {
    super.initState();

    // 先加载视频详情
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 延迟 1 秒加载推荐视频
      Future.delayed(const Duration(milliseconds: 300), () {
        ref
            .read(videoDetailProvider(widget.videoInfo.id).notifier)
            .getRecommendedVideos(widget.videoInfo.id);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final videoInfo = widget.videoInfo;

    final videoState = ref.watch(videoDetailProvider(videoInfo.id)); // 自动刷新
    final recommendedVideos = videoState.recommendedVideos;
    final isLoadingRecommended = videoState.recommendedVideosLoading;

    final headerChildren = <Widget>[
      UserInfoRow(
        userId: videoInfo.userId,
        avatarUrl: videoInfo.user.avatar ?? '',
        nickname: videoInfo.user.nickname ?? "",
        fansCount: videoInfo.user.fansCount ?? 0,
        isFollowed: videoInfo.isFollow,
        vip: videoInfo.user.vip,
        onFollowPressed: (value) async {
          widget.onFollowPressed?.call(value);
        },
      ),
      const SizedBox(height: 16),
      VideoInfoRow(
        title: videoInfo.title,
        views: videoInfo.viewCount,
        comments: videoInfo.commentCount,
        publishTime: DateFormat('yyyy-MM-dd HH:mm').format(videoInfo.createdAt),
        description: videoInfo.description,
        expanded: _expanded,
        onToggleExpanded: () {
          setState(() {
            _expanded = !_expanded;
          });
        },
      ),
      const SizedBox(height: 16),
      if (widget.ads.isNotEmpty) ...[
        AdBannerCarousel(ads: widget.ads),
        const SizedBox(height: 16),
      ],
      VideoTagCategoryWrap(
        tags: widget.videoInfo.tags,
        categories: widget.videoInfo.categories,
        categoryColor: Colors.white,
        fontSize: 15,
      ),
      const SizedBox(height: 16),
      VideoActionRow(
        isFavorited: videoInfo.isFavorite,
        isLiked: videoInfo.isLike,
        likes: videoInfo.likeCount,
        favorites: videoInfo.favoriteCount,
        shares: 10,
        onLike: (value) async {
          widget.onLike?.call(value);
        },
        onFavorite: (value) async {
          widget.onFavorite?.call(value);
        },
        onShare: widget.onShare ?? () {},
        videoInfo: videoInfo,
      ),
      const SizedBox(height: 24),
    ];

    return CustomScrollView(
      key: PageStorageKey('video-description-${videoInfo.id}'),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverList(
            delegate: SliverChildListDelegate.fixed(headerChildren),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (recommendedVideos.isNotEmpty) {
                  return RecommendedVideoItem(
                    video: recommendedVideos[index],
                    onTap: widget.onRecommendedVideoTap,
                  );
                }
                if (isLoadingRecommended) {
                  return const RecommendedVideoSkeleton();
                }
                return null;
              },
              childCount: recommendedVideos.isNotEmpty
                  ? recommendedVideos.length
                  : (isLoadingRecommended ? 5 : 0),
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: true,
            ),
          ),
        ),
      ],
    );
  }
}
