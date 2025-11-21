import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/video_info.dart';
import '../../utils/text_util.dart';
import '../encrypted_image.dart';

class RecommendedVideoItem extends StatelessWidget {
  final VideoInfo video;
  final void Function(VideoInfo)? onTap;

  const RecommendedVideoItem({super.key, required this.video, this.onTap});

  @override
  Widget build(BuildContext context) {
    final publishDate = DateFormat(
      'yyyy-MM-dd',
    ).format(video.createdAt); // 格式化发布日期

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap?.call(video),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Stack(
              children: [
                // 封面
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: EncryptedImage(
                    url: video.cover,
                    width: 140,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                ),

                /// 底部阴影层
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 30,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xAF000000)],
                      ),
                    ),
                  ),
                ),

                /// 底部文字信息
                Positioned(
                  bottom: 3,
                  left: 3,
                  right: 3,
                  child: Align(
                    alignment: Alignment.centerRight, // 靠右
                    child: Text(
                      formatDuration(video.duration),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 12),
            // 标题、头像和信息
            Expanded(
              child: SizedBox(
                height: 90,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题
                    Text(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis, // 超出显示省略号
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    // 用户信息和发布日期
                    Row(
                      children: [
                        const Icon(
                          Icons.play_arrow,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${video.viewCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.comment,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${video.commentCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),
                    Row(
                      children: [
                        UserAvatar(
                          userId: video.userId,
                          url: video.user.avatar ??"https://i.pravatar.cc/350",
                          nickname: video.user.nickname,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        // 昵称
                        Expanded(
                          child: Text(
                            video.user.nickname??"",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // 发布时间
                        Text(
                          publishDate,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecommendedVideoSkeleton extends StatelessWidget {
  const RecommendedVideoSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // 封面骨架
          Container(
            width: 140,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          // 右侧文本骨架
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: double.infinity,
                  color: Colors.grey[800],
                ),
                const SizedBox(height: 6),
                Container(height: 12, width: 100, color: Colors.grey[800]),
                const SizedBox(height: 6),
                Container(height: 12, width: 60, color: Colors.grey[800]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
