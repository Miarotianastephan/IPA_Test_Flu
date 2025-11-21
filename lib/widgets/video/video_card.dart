import 'package:flutter/material.dart';
import 'package:live_app/widgets/encrypted_image.dart';

import '../../models/video_info.dart';
import '../../page/long_video_detail_page.dart';
import '../../page/user_detail_page.dart';
import '../../utils/responsive_utils.dart';
import '../../utils/text_util.dart';

class VideoCard extends StatefulWidget {
  const VideoCard({super.key, required this.video, this.onUserTap});

  final VideoInfo video;

  /// 用户点击头像/昵称事件，可选

  final Function(VideoInfo videoInfo)? onUserTap;

  /// 默认方法
  void defaultOnUserTap(BuildContext context, int userId) {
    // 这里可以打开用户详情页
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserDetailPage(user: video.user)),
    );
  }

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  void _openVideoDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LongVideoDetailPage(video: widget.video),
      ),
    );
  }

  void _handleUserTap() {
    if (widget.onUserTap != null) {
      widget.onUserTap!(widget.video);
    } else {
      // 默认行为
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserDetailPage(user: widget.video.user),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveDimensions(context);

    return GestureDetector(
      onTap: _openVideoDetail,
      child: SizedBox(
        height: 500,
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
                      height:
                          MediaQuery.of(context).size.width /
                          responsive.videoCardImageRatio,
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
                                size: responsive.videoCardIconSize,
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
              Flexible(
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
              SizedBox(height: 4),

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
                        url:
                            widget.video.user.avatar ??
                            "https://i.pravatar.cc/350",
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
