import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/video_info.dart';
import 'package:live_app/provider/api_provider.dart';
import 'package:live_app/provider/current_user_provider.dart';
import 'package:live_app/widgets/comment/comments_modal.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

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

  late final Player _player;
  late final VideoController _videoController;

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

    _player = Player(configuration: const PlayerConfiguration(muted: false));

    _player.open(
      Media(widget.videoInfo.url),
      play: kIsWeb ? true : false, 
    );

    _videoController = VideoController(_player);
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
            final offset = (1 - t) * height;// 初始在底部，逐渐上移
            return Positioned(
              left: 0,
              right: 0,
              bottom: -offset,
              // 控制从下往上滑
              height: height,
              child: GestureDetector(
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
    _player.dispose();
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
            _player.pause();
          } else if (info.visibleFraction > 0.8) {
            _player.play();
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
                        return SizedBox(height: height);
                      },
                    ),
                    AnimatedBuilder(
                      animation: _transitionController,
                      builder: (context, child) {
                        final t = _transitionController.value;

                      
                        final containerHeight =
                            availableHeight * (1 - t) +
                            (availableHeight * 0.4 - mediaQuery.padding.top) *
                                t;

                       //竖屏全屏：视频铺满整个容器
                        return SizedBox(
                          height: containerHeight,
                          width: double.infinity,
                          child: Video(
                            controller: _videoController,
                            controls: null,
                            fit: video.type == 2
                                ? BoxFit.contain
                                : BoxFit
                                      .cover,
                          ),
                        );
                      },
                    ),

                    AnimatedBuilder(
                      animation: _transitionController,
                      builder: (context, child) {
                        final t = _transitionController.value;
                        final height = t * availableHeight * 0.6;
                        return SizedBox(height: height);
                      },
                    ),
                  ],
                );
              },
            ),

            StreamBuilder<bool>(
              stream: _player.stream.buffering,
              builder: (context, snapshot) {
                final buffering = snapshot.data ?? false;
                if (!buffering) return const SizedBox.shrink();

                return Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                );
              },
            ),

            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (_player.state.playing) {
                    _player.pause();
                  } else {
                    _player.play();
                  }
                },
                child: Center(
                  child: StreamBuilder<bool>(
                    stream: _player.stream.playing,
                    builder: (context, snapshot) {
                      final isPlaying = snapshot.data ?? false;

                      return AnimatedOpacity(
                        opacity: isPlaying ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                           
                            GestureDetector(
                              onTap: () {
                                final pos = _player.state.position;
                                final newPos =
                                    pos - const Duration(seconds: 10);
                                _player.seek(
                                  newPos < Duration.zero
                                      ? Duration.zero
                                      : newPos,
                                );
                              },
                              child: Container(
                                width: 45,
                                height: 45,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(95, 0, 0, 0),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.replay_10,
                                  color: Colors.white,
                                  size: 25,
                                ),
                              ),
                            ),

                            const SizedBox(width: 20),

                          
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(95, 0, 0, 0),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),

                            const SizedBox(width: 20),

                          
                            GestureDetector(
                              onTap: () {
                                final pos = _player.state.position;
                                final dur = _player.state.duration;

                                final newPos =
                                    pos + const Duration(seconds: 10);
                                _player.seek(newPos > dur ? dur : newPos);
                              },
                              child: Container(
                                width: 45,
                                height: 45,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(95, 0, 0, 0),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.forward_10,
                                  color: Colors.white,
                                  size: 25,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: StreamBuilder<Duration>(
                stream: _player.stream.position,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final duration = _player.state.duration;

                  final progress = duration.inMilliseconds == 0
                      ? 0.0
                      : position.inMilliseconds / duration.inMilliseconds;

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragUpdate: (details) {
                      final box = context.findRenderObject() as RenderBox;
                      final dx = box.globalToLocal(details.globalPosition).dx;
                      final x = (dx / box.size.width).clamp(0.0, 1.0);
                      _player.seek(duration * x);
                    },
                    onTapDown: (details) {
                      final box = context.findRenderObject() as RenderBox;
                      final dx = box.globalToLocal(details.globalPosition).dx;
                      final x = (dx / box.size.width).clamp(0.0, 1.0);
                      _player.seek(duration * x);
                    },
                    child: SizedBox(
                      height: 6,
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white30,
                        valueColor: const AlwaysStoppedAnimation(
                          Color.fromARGB(255, 54, 174, 244),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          
            Positioned.fill(
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
                  setState(() => _isFollowed = value);
                  widget.onVideoInfoChange(video.copyWith(isFollow: value));
                },
                onLikeChanged: (value) async {
                  if (value) {
                    await videoService.likeVideo(video.id);
                  } else {
                    await videoService.unlikeVideo(video.id);
                  }
                  setState(() => _isLike = value);
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
                    await videoService.favoriteVideo(video.id);
                  } else {
                    await videoService.unFavoriteVideo(video.id);
                  }
                  setState(() => _isFavorite = value);
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
