import 'package:flutter/material.dart';
import 'package:live_app/widgets/video/video_stat_item.dart';
import 'package:live_app/widgets/video/video_tag_category_wrap.dart';
import 'package:live_app/widgets/video/video_grid_item.dart';

import '../../models/video_info.dart';
import '../encrypted_image.dart';
import '../network_image_with_measure.dart';

class VideoGridItem extends StatelessWidget {
  final VideoInfo video;
  final double? knownHeight;
  final String heroTagPrefix;
  final int index;
  final int? activeHeroIndex;
  final Function(int) onTapItem;
  final Function() onUserTap;
  final Function(double) onMeasured;
  final double columnWidth;

  const VideoGridItem({
    super.key,
    required this.video,
    required this.knownHeight,
    required this.heroTagPrefix,
    required this.index,
    required this.activeHeroIndex,
    required this.onTapItem,
    required this.onUserTap,
    required this.onMeasured,
    required this.columnWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: columnWidth,
            height: knownHeight,
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
                        ? Container(color: Colors.transparent)
                        : NetworkImageWithMeasure(
                            imageUrl: video.cover,
                            onImageMeasured: (h) {
                              onMeasured(h);
                            },
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
                          const SizedBox(height: 4),

                          // 用户信息
                          GestureDetector(
                            onTap: onUserTap,
                            child: Row(
                              children: [
                                UserAvatar(
                                  userId: video.userId,
                                  url: video.user.avatar,
                                  nickname: video.user.nickname,
                                  size: 20,
                                  onTap: onUserTap,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
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
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // 文字、覆盖层
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
                    icon: video.isLike ? Icons.favorite : Icons.favorite_border,
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
                  ),
                  VideoStatItem(icon: Icons.comment, count: video.commentCount),
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
