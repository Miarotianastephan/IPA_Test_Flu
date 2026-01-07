import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/page/short_video_page.dart';

import 'package:live_app/widgets/encrypted_image.dart';

import '../../models/video_info.dart';
import '../../page/long_video_detail_page.dart';
import '../../utils/responsive_utils.dart';
import '../../utils/text_util.dart';
import '../../utils/utils.dart';

class VideoCard extends ConsumerStatefulWidget {
  const VideoCard({super.key, required this.video, this.onUserTap});

  final VideoInfo video;
  final Function(VideoInfo videoInfo)? onUserTap;

  @override
  ConsumerState<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends ConsumerState<VideoCard> {
  void _openVideoDetail(VideoInfo video) {
    widget.video.type == 2
        ? Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LongVideoDetailPage(video: widget.video),
            ),
          )
        : Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShortVideoPage(videoId: video.id),
            ),
          );
  }

  void _handleUserTap() {
    // 默认行为：使用 userId 打开用户详情页，强制从 API 加载最新数据
    toUserDetailPage(
      context: context,
      ref: ref,
      userId: widget.video.user.id,
      url: widget.video.user.avatar,
      nickname: widget.video.user.nickname,
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveDimensions(context);

    final screenWidth = MediaQuery.of(context).size.width;

    final cardHeight = widget.video.type == 2
        ? screenWidth * 9 / 16
        : screenWidth * 4 / 5;
    final height = widget.video.type == 2
        ? screenWidth * 0.3
        : screenWidth * 2 / 3.1;
    return GestureDetector(
      onTap: () {
        _openVideoDetail(widget.video);
      },
      child: SizedBox(
        height: cardHeight,
        child: Card(
          color: Colors.black,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 封面 + 阴影 + 底部信息
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(5),
                ),
                child: Stack(
                  children: [
                    /// 视频封面图
                    EncryptedImage(
                      url: widget.video.cover,
                      height: height,
                      width: double.infinity,
                      fit: BoxFit.cover,
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /// 左侧：播放量 + 评论数
                          Row(
                            children: [
                              Icon(
                                Icons.play_arrow,
                                size: 20,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${widget.video.viewCount}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: responsive.videoCardInfoFontSize,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(
                                Icons.comment,
                                size: responsive.videoCardIconSize,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${widget.video.commentCount}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: responsive.videoCardInfoFontSize,
                                ),
                              ),
                            ],
                          ),

                          /// 右侧：视频时长
                          Text(
                            formatDuration(widget.video.duration),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: responsive.videoCardInfoFontSize,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              /// 标题
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.videoCardHorizontalPadding,
                    vertical: responsive.videoCardVerticalPadding,
                  ),
                  child: Text(
                    widget.video.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: responsive.videoCardTitleFontSize,
                      color: Colors.white,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              /// 用户信息
              Padding(
                padding: EdgeInsets.only(
                  left: responsive.videoCardHorizontalPadding,
                  right: responsive.videoCardHorizontalPadding,
                  bottom: responsive.videoCardVerticalPadding,
                ),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _handleUserTap,
                  child: Row(
                    children: [
                      UserAvatar(
                        userId: widget.video.userId,
                        url: widget.video.user.avatar,
                        nickname: widget.video.user.nickname,
                        size: responsive.videoCardAvatarSize,
                        onTap: _handleUserTap,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          widget.video.user.nickname ?? "",
                          style: TextStyle(
                            fontSize: responsive.videoCardNicknameFontSize,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
    );
  }
}
