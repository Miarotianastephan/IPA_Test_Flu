import 'package:flutter/material.dart';
import 'package:live_app/widgets/video/video_stat_item.dart';
import 'package:live_app/widgets/video/video_tag_category_wrap.dart';
import 'package:live_app/widgets/vip_badge.dart';

import '../../models/video_info.dart';
import '../encrypted_image.dart';
import 'video_card_cover_slot.dart';

class VideoGridItem extends StatelessWidget {
  final VideoInfo video;
  final double? knownHeight;
  final String heroTagPrefix;
  final int index;
  final int? activeHeroIndex;
  final bool hasPurchased;
  final String? purchasedLabel;
  final Function(int) onTapItem;
  final Function() onUserTap;
  final double columnWidth;
  final bool hideUserInfo;
  final List<String> preloadCoverUrls;

  const VideoGridItem({
    super.key,
    required this.video,
    required this.knownHeight,
    required this.heroTagPrefix,
    required this.index,
    required this.activeHeroIndex,
    this.hasPurchased = false,
    this.purchasedLabel,
    required this.onTapItem,
    required this.onUserTap,
    required this.columnWidth,
    this.hideUserInfo = false,
    this.preloadCoverUrls = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              onTapItem(index);
            },
            child: Stack(
              children: [
                Hero(
                  tag: "${heroTagPrefix}_${video.id}",
                  placeholderBuilder: (context, heroSize, child) {
                    return child;
                  },
                  child: activeHeroIndex == index
                      ? SizedBox(width: columnWidth, height: knownHeight ?? 300)
                      : ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: video.type == 2 ? 145 : 300,
                          ),
                          child: RepaintBoundary(
                            child: Container(
                              color: const Color(0xFF161616),
                              child: VideoCardCoverSlot(
                                videoId: video.id,
                                coverUrl: video.cover,
                                videoType: video.type,
                                preloadCoverUrls: preloadCoverUrls,
                                useContentConstraintsForImage: true,
                                placeholder: const SizedBox.expand(
                                  child: ColoredBox(color: Color(0xFF161616)),
                                ),
                                errorWidget: const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
                if (hasPurchased)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black87,
                            blurRadius: 4,
                            spreadRadius: 1,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        purchasedLabel ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                // 底部信息层
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.8),
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 6,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 标题，两行省略
                        Text(
                          video.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                          ),
                        ),
                        if (!hideUserInfo) ...[
                          const SizedBox(height: 4),

                          // 用户信息
                          GestureDetector(
                            onTap: onUserTap,
                            child: Row(
                              children: [
                                RepaintBoundary(
                                  child: UserAvatar(
                                    userId: video.userId,
                                    url: video.user.avatar,
                                    nickname: video.user.nickname,
                                    vip: video.user.vip,
                                    size: 20,
                                    onTap: onUserTap,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          video.user.nickname ?? "",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                      VipBadge(vip: video.user.vip, size: 11),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        if (!hideUserInfo)
          // 统计、标签
          Container(
            color: Colors.black.withValues(alpha: 0.4),
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
            child: Column(
              children: [
                // 点赞 / 收藏 / 观看数量 / 评论数量
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    VideoStatItem(
                      icon: video.isLike
                          ? Icons.favorite
                          : Icons.favorite_border,
                      hasColor: video.isLike,
                      color: Colors.red,
                      count: video.likeCount,
                    ),
                    VideoStatItem(
                      icon: video.isFavorite
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      hasColor: video.isFavorite,
                      color: Colors.yellow,
                      count: video.favoriteCount,
                    ),
                    VideoStatItem(
                      icon: Icons.play_arrow_rounded,
                      count: video.viewCount,
                      size: 20,
                    ),
                    VideoStatItem(
                      icon: Icons.comment,
                      count: video.commentCount,
                    ),
                  ],
                ),

                const SizedBox(height: 6),
                // 标签 + 分类
                VideoTagCategoryWrap(
                  tags: video.tags,
                  categories: video.categories,
                ),

                const SizedBox(height: 6),
              ],
            ),
          ),
      ],
    );
  }
}
