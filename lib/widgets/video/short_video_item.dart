import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/video_info.dart';
import 'package:live_app/provider/api_provider.dart';
import 'package:live_app/widgets/comment/comments_modal.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../api/services/video_service.dart';
import '../../page/comment_detail_page.dart';
import '../../provider/cureent_video_user_provider.dart';
import 'video_overlay_actions.dart';

class ShortVideoItemController extends ChangeNotifier {
  bool? _isFollowed;
  bool? _isLike;
  bool? _isFavorite;
  int? _commentCount;

  void updateFollowed(bool value) {
    _isFollowed = value;
    notifyListeners();
  }

  void updateLike(bool value) {
    _isLike = value;
    notifyListeners();
  }

  void updateFavorite(bool value) {
    _isFavorite = value;
    notifyListeners();
  }

  void updateCommentCount(int value) {
    _commentCount = value;
    notifyListeners();
  }

  bool? get isFollowed => _isFollowed;

  bool? get isLike => _isLike;

  bool? get isFavorite => _isFavorite;

  int? get commentCount => _commentCount;
}

class ShortVideoItem extends ConsumerStatefulWidget {
  final VideoInfo videoInfo;
  final Function(VideoInfo videoInfo) onUserTap;
  final VoidCallback? onShowComment;
  final VoidCallback? onHideComment;
  final Function(VideoInfo videoInfo) onVideoInfoChange;
  final ShortVideoItemController? controller;

  const ShortVideoItem({
    super.key,
    required this.videoInfo,
    required this.onUserTap,
    this.onShowComment,
    this.onHideComment,
    required this.onVideoInfoChange,
    this.controller,
  });

  @override
  ConsumerState<ShortVideoItem> createState() => ShortVideoPageStat();
}

class ShortVideoPageStat extends ConsumerState<ShortVideoItem>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late bool _isFollowed;
  late bool _isLike;
  late bool _isFavorite;
  late int _commentCount;
  bool _modalOpen = false;
  late final VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  late AnimationController _transitionController;
  late final VideoService videoService;

  @override
  void initState() {
    super.initState();

    _isFollowed = widget.videoInfo.isFollow;
    _isLike = widget.videoInfo.isLike;
    _isFavorite = widget.videoInfo.isFavorite;
    _commentCount = widget.videoInfo.commentCount;

    widget.controller?.addListener(() {
      if (mounted) {
        setState(() {
          if (widget.controller!.isFollowed != null) {
            _isFollowed = widget.controller!.isFollowed!;
          }
          if (widget.controller!.isLike != null) {
            _isLike = widget.controller!.isLike!;
          }
          if (widget.controller!.isFavorite != null) {
            _isFavorite = widget.controller!.isFavorite!;
          }
          if (widget.controller!.commentCount != null) {
            _commentCount = widget.controller!.commentCount!;
          }
        });
      }
    });

    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      videoService = ref.read(videoServiceProvider);
      ref.read(currentUserProvider.notifier).state = widget.videoInfo.user;
    });

    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoInfo.url),
      // Uri.parse("https://assets.mixkit.co/videos/51792/51792-720.mp4"),
    );

    _videoPlayerController.initialize().then((_) {
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        showControls: true,
        autoPlay: kIsWeb,
        looping: true,
      );
      setState(() {});
    });
  }

  Future<void> _showModal(height) async {
    setState(() {
      _modalOpen = true;
    });
    widget.onShowComment?.call();
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    // 打开时执行正向动画
    _transitionController.forward(from: 0);

    double? dragStartX;

    entry = OverlayEntry(
      builder: (context) {
        return AnimatedBuilder(
          animation: _transitionController,
          builder: (context, child) {
            final t = _transitionController.value;
            final offset = (1 - t) * height; // 初始在底部，逐渐上移
            return Positioned(
              left: 0,
              right: 0,
              bottom: -offset,
              // 控制从下往上滑
              height: height,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    onHorizontalDragStart: (details) {
                      dragStartX = details.globalPosition.dx;
                    },
                    onHorizontalDragUpdate: (details) {
                      if (dragStartX != null &&
                          dragStartX! < 50 &&
                          details.primaryDelta != null &&
                          details.primaryDelta! > 20) {
                        _transitionController.reverse().then((_) {
                          entry.remove();
                          setState(() {
                            _modalOpen = false;
                          });
                          widget.onHideComment?.call();
                        });
                      }
                    },
                    child: Material(
                      color: Colors.white,
                      elevation: 12,
                      child: Column(
                        children: [
                          Expanded(
                            child: CommentsModal(
                              videoId: widget.videoInfo.id,
                              height: height,
                              transitionController: _transitionController,
                              onTapClose: () async {
                               await _transitionController.reverse();
                                entry.remove();
                                setState(() {
                                  _modalOpen = false;
                                });
                                widget.onHideComment?.call();
                              },
                              onComment: () {
                                setState(() {
                                  _commentCount = _commentCount + 1;
                                });
                              },
                              onCommentTap: (comment) async {
                                final navigator = Navigator.of(context);

                                _transitionController.reverse();
                                entry.remove();
                                setState(() {
                                  _modalOpen = false;
                                });
                                widget.onHideComment?.call();

                                if (!mounted) return;
                                await navigator.push(
                                  MaterialPageRoute(
                                    builder: (context) => CommentDetailPage(
                                      parentComment: comment,
                                      videoId: widget.videoInfo.id,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );

    overlay.insert(entry);
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final video = widget.videoInfo;
    final mediaQuery = MediaQuery.of(context);
    var availableHeight = 0.0;
    return PopScope(
      canPop: !_modalOpen, // 控制是否允许系统返回
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && _modalOpen) {
          await _transitionController.reverse();
          setState(() {
            _modalOpen = false;
          });
          widget.onHideComment?.call();
        }
      },
      child: VisibilityDetector(
        key: Key(widget.videoInfo.id.toString()),
        onVisibilityChanged: (info) {
          if (info.visibleFraction == 0) {
            _videoPlayerController.pause();
          } else if (info.visibleFraction > 0.8) {
            _videoPlayerController.play();
          }
        },
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                availableHeight = constraints.maxHeight;
                return Column(
                  children: [
                    AnimatedBuilder(
                      animation: _transitionController,
                      builder: (context, child) {
                        final t = _transitionController.value;
                        final height = t * mediaQuery.padding.top;
                        return SizedBox(height: height, child: Container());
                      },
                    ),

                    AnimatedBuilder(
                      animation: _transitionController,
                      builder: (context, child) {
                        final t = _transitionController.value;
                        final videoValue = _videoPlayerController.value;
                        final isPortrait =
                            videoValue.size.height > videoValue.size.width;

                        final containerHeight =
                            availableHeight * (1 - t) +
                            (availableHeight * 0.4 - mediaQuery.padding.top) *
                                t;

                        if (_chewieController == null) {
                          return SizedBox(
                            height: containerHeight,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (isPortrait) {
                          if (t == 0) {
                            //竖屏全屏：视频铺满整个容器
                            return SizedBox(
                              height: containerHeight,
                              width: double.infinity,
                              child: FittedBox(
                                fit: BoxFit.cover,
                                clipBehavior: Clip.hardEdge,
                                child: SizedBox(
                                  width: videoValue.size.width,
                                  height: videoValue.size.height,
                                  child: Chewie(controller: _chewieController!),
                                ),
                              ),
                            );
                          } else {
                            // 竖屏缩放：高度保持视频高度，只改变宽度
                            final videoHeight = videoValue.size.height;
                            final videoWidth = videoValue.size.width;

                            // 比例缩放，只动宽度
                            final scale = 1 - t * 0.5; // 这里控制缩放幅度
                            return SizedBox(
                              height: containerHeight,
                              child: Align(
                                alignment: Alignment.center,
                                child: SizedBox(
                                  height: videoHeight,
                                  width: videoWidth * scale,
                                  child: Chewie(controller: _chewieController!),
                                ),
                              ),
                            );
                          }
                        } else {
                          // 横屏视频：用 AspectRatio 保持比例
                          return SizedBox(
                            height: containerHeight,
                            width: double.infinity,
                            child: AspectRatio(
                              aspectRatio: videoValue.aspectRatio,
                              child: Chewie(controller: _chewieController!),
                            ),
                          );
                        }
                      },
                    ),

                    AnimatedBuilder(
                      animation: _transitionController,
                      builder: (context, child) {
                        final t = _transitionController.value;
                        final height = t * availableHeight * 0.6;
                        return SizedBox(height: height, child: Container());
                      },
                    ),
                  ],
                );
              },
            ),

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: VideoOverlayActions(
                commentCount: _commentCount,
                video: video,
                isFollowed: _isFollowed,
                isLike: _isLike,
                isFavorite: _isFavorite,
                onUserTap: widget.onUserTap,
                showModal: () async {
                  _showModal(mediaQuery.size.height - availableHeight * 0.4);
                },
                onFollowChanged: (value) async {
                  setState(() {
                    _isFollowed = value;
                  });
                  widget.onVideoInfoChange(video.copyWith(isFollow: value));
                },
                onLikeChanged: (value) async {
                  if (value) {
                    await videoService.likeVideo(widget.videoInfo.id);
                  } else {
                    await videoService.unlikeVideo(widget.videoInfo.id);
                  }
                  setState(() {
                    _isLike = value;
                  });
                  widget.onVideoInfoChange(
                    video.copyWith(
                      isLike: value,
                      likeCount: value
                          ? video.likeCount + 1
                          : video.likeCount - 1,
                    ),
                  );
                },
                onFavoriteChanged: (value) async {
                  if (value) {
                    await videoService.favoriteVideo(widget.videoInfo.id);
                  } else {
                    await videoService.unFavoriteVideo(widget.videoInfo.id);
                  }
                  setState(() {
                    _isFavorite = value;
                  });
                  widget.onVideoInfoChange(
                    video.copyWith(
                      isFavorite: value,
                      favoriteCount: value
                          ? video.favoriteCount + 1
                          : video.favoriteCount - 1,
                    ),
                  );
                },
                onHidden: (bool value) {
                  if (value) {
                    widget.onHideComment?.call();
                  } else {
                    widget.onShowComment?.call();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
