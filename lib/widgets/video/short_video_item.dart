import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/video_info.dart';
import 'package:live_app/provider/api_provider.dart';
import 'package:live_app/provider/cureent_video_user_provider.dart';
import 'package:live_app/widgets/comment/comments_modal.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../api/services/video_service.dart';
import '../../page/comment_detail_page.dart';
import 'video_overlay_actions.dart';
import 'short_video_item_stub.dart'
    if (dart.library.io) 'short_video_item_mobile_impl.dart'
    if (dart.library.html) 'short_video_item_web_impl.dart' as platform_impl;

class ShortVideoItemController extends ChangeNotifier {
  bool? _isFollowed;
  bool? _isLike;
  bool? _isFavorite;
  int? _commentCount;

  void updateFollowed(bool v) {
    _isFollowed = v;
    notifyListeners();
  }

  void updateLike(bool v) {
    _isLike = v;
    notifyListeners();
  }

  void updateFavorite(bool v) {
    _isFavorite = v;
    notifyListeners();
  }

  void updateCommentCount(int v) {
    _commentCount = v;
    notifyListeners();
  }

  bool? get isFollowed => _isFollowed;
  bool? get isLike => _isLike;
  bool? get isFavorite => _isFavorite;
  int? get commentCount => _commentCount;
}

class ShortVideoItem extends ConsumerStatefulWidget {
  final VideoInfo videoInfo;
  final Function(VideoInfo video) onUserTap;
  final VoidCallback? onInitialized;
  final VoidCallback? onShowComment;
  final VoidCallback? onHideComment;
  final Function(VideoInfo video) onVideoInfoChange;
  final VoidCallback? onReset;
  final ShortVideoItemController? controller;

  const ShortVideoItem({
    super.key,
    required this.videoInfo,
    required this.onUserTap,
    required this.onVideoInfoChange,
    this.onInitialized,
    this.onShowComment,
    this.onHideComment,
    this.onReset,
    this.onBufferingChanged,
    this.controller,
  });

  final Function(bool isBuffering)? onBufferingChanged;

  @override
  ConsumerState<ShortVideoItem> createState() => _ShortVideoItemState();
}

class _ShortVideoItemState extends ConsumerState<ShortVideoItem>
    with SingleTickerProviderStateMixin {
  late bool _isFollowed;
  late bool _isLike;
  late bool _isFavorite;
  late int _commentCount;

  bool _modalOpen = false;
  bool _showVideo = false;
  bool _hasCalledOnInitialized = false;

  late AnimationController _transitionController;

  double _maxAvailableHeight = 0;
  bool _isKeyboardOpen = false;

  late VideoService videoService;
  platform_impl.PlatformVideoPlayer? _platformPlayer;

  @override
  void didUpdateWidget(ShortVideoItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videoInfo.url != oldWidget.videoInfo.url) {
      _showVideo = false;
      _hasCalledOnInitialized = false;

      widget.onReset?.call();
      _disposePlayer();
      _initializeVideo();
    }
  }

  void _disposePlayer() {
    _platformPlayer?.dispose();
    _platformPlayer = null;
  }

  @override
  void initState() {
    super.initState();

    videoService = ref.read(videoServiceProvider);

    final v = widget.videoInfo;
    _isFollowed = v.isFollow;
    _isLike = v.isLike;
    _isFavorite = v.isFavorite;
    _commentCount = v.commentCount;

    widget.controller?.addListener(() {
      if (!mounted) return;
      setState(() {
        _isFollowed = widget.controller!.isFollowed ?? _isFollowed;
        _isLike = widget.controller!.isLike ?? _isLike;
        _isFavorite = widget.controller!.isFavorite ?? _isFavorite;
        _commentCount = widget.controller!.commentCount ?? _commentCount;
      });
    });

    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _initializeVideo();
  }

  void _onPlayerStateChanged() {
    if (!mounted) return;
    setState(() {});
    _notifyIfReady();
  }

  Future<void> _initializeVideo() async {
    _platformPlayer = platform_impl.createPlatformVideoPlayer(
      videoService: videoService,
      onStateChanged: _onPlayerStateChanged,
    );

    await _platformPlayer!.initialize(
      widget.videoInfo.url,
      widget.videoInfo.encryptionKey ?? 'fsjkey',
    );

    if (mounted) {
      setState(() {});
      _notifyIfReady();
    }
  }

  void _notifyIfReady() {
    if (!mounted || _platformPlayer == null) return;

    final isInitialized = _platformPlayer!.isInitialized;
    final isBuffering = _platformPlayer!.isBuffering;

    if (!isInitialized) {
      widget.onBufferingChanged?.call(true);
      return;
    }

    final bool effectivelyReady = !isBuffering;

    if (effectivelyReady) {
      if (!_hasCalledOnInitialized) {
        _hasCalledOnInitialized = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onInitialized?.call();
        });

        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() {
              _showVideo = true;
            });
          }
        });
      }
      widget.onBufferingChanged?.call(false);
    } else {
      widget.onBufferingChanged?.call(true);
    }
  }

  Future<void> _showModal(double height) async {
    setState(() {
      _modalOpen = true;
    });
    widget.onShowComment?.call();

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    _transitionController.forward(from: 0);

    entry = OverlayEntry(
      builder: (_) {
        return AnimatedBuilder(
          animation: _transitionController,
          builder: (context, child) {
            final t = _transitionController.value;
            final offset = (1 - t) * height;
            return Positioned(
              left: 0,
              right: 0,
              bottom: -offset,
              height: height,
              child: child!,
            );
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
                setState(() => _commentCount++);
              },
              onCommentTap: (comment) async {
                await _transitionController.reverse();
                entry.remove();
                setState(() {
                  _modalOpen = false;
                });
                widget.onHideComment?.call();

                if (!mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CommentDetailPage(
                      parentComment: comment,
                      videoId: widget.videoInfo.id,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    overlay.insert(entry);
  }

  @override
  void dispose() {
    _transitionController.dispose();
    _disposePlayer();
    super.dispose();
  }

  bool get _isPlaying => _platformPlayer?.isPlaying ?? false;

  bool get _isInitialized => _platformPlayer?.isInitialized ?? false;

  void _play() {
    _platformPlayer?.play();
  }

  void _pause() {
    _platformPlayer?.pause();
  }

  void _seekTo(Duration position) {
    _platformPlayer?.seekTo(position);
  }

  Widget _buildProgressSlider(BuildContext context) {
    if (_platformPlayer == null) return const SizedBox.shrink();

    final position = _platformPlayer!.position;
    final duration = _platformPlayer!.duration;

    final progress = (duration.inMilliseconds == 0)
        ? 0.0
        : position.inMilliseconds / duration.inMilliseconds;

    return _buildSlider(context, position, duration, progress);
  }

  Widget _buildSlider(
    BuildContext context,
    Duration position,
    Duration duration,
    double progress,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) {
        final box = context.findRenderObject() as RenderBox;
        final dx = box.globalToLocal(details.globalPosition).dx;
        final x = (dx / box.size.width).clamp(0.0, 1.0);
        _seekTo(duration * x);
      },
      onHorizontalDragUpdate: (details) {
        final box = context.findRenderObject() as RenderBox;
        final dx = box.globalToLocal(details.globalPosition).dx;
        final x = (dx / box.size.width).clamp(0.0, 1.0);
        _seekTo(duration * x);
      },
      child: SizedBox(
        height: 6,
        child: MaterialWrapper(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white30,
              thumbColor: Colors.white,
              overlayColor: Colors.white24,
            ),
            child: Slider(
              value: progress.isNaN ? 0.0 : progress.clamp(0.0, 1.0),
              onChanged: (value) {
                _seekTo(duration * value);
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final video = widget.videoInfo;

    double availableHeight = 0;
    bool isPlaying = _isPlaying;

    return PopScope(
      canPop: !_modalOpen,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && _modalOpen) {
          await _transitionController.reverse();
          setState(() {
            _modalOpen = false;
          });
          widget.onHideComment?.call();
        }
      },
      child: VisibilityDetector(
        key: Key('visibility_${video.id}_$hashCode'),
        onVisibilityChanged: (info) {
          if (info.visibleFraction == 0) {
            _pause();
          } else if (info.visibleFraction > 0.65) {
            ref.read(currentVideoUserProvider.notifier).state = video.user;
            _play();
          }
        },
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (builderContext, constraints) {
                availableHeight = constraints.maxHeight;

                if (availableHeight > _maxAvailableHeight) {
                  _maxAvailableHeight = availableHeight;
                }

                final heightDifference = _maxAvailableHeight - availableHeight;
                _isKeyboardOpen = heightDifference > 100;

                final actualVideoHeight = (_modalOpen && _isKeyboardOpen)
                    ? availableHeight * 0.68
                    : availableHeight;

                return Container(
                  height: actualVideoHeight,
                  width: double.infinity,
                  color: Colors.black,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          video.cover,
                          fit: video.type == 2 ? BoxFit.contain : BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(color: Colors.black),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(color: Colors.black);
                          },
                        ),
                      ),

                      if (_isInitialized)
                        Positioned.fill(
                          child: AnimatedOpacity(
                            opacity: _showVideo ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 250),
                            child: Container(
                              color: Colors.black,
                              child: Center(
                                child: _platformPlayer?.buildVideoWidget(
                                  fit: video.type == 2
                                      ? BoxFit.contain
                                      : BoxFit.cover,
                                ) ?? const SizedBox.shrink(),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),

            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (!_isInitialized) return;
                  if (_isPlaying) {
                    _pause();
                    setState(() => isPlaying = false);
                  } else {
                    _play();
                    setState(() => isPlaying = true);
                  }
                },
                child: Center(
                  child: !isPlaying
                      ? Container(
                          width: 100,
                          height: 100,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white.withOpacity(0.4),
                            size: 100,
                          ),
                        )
                      : const SizedBox(),
                ),
              ),
            ),
            if (_isInitialized)
              Positioned(
                left: 0,
                right: 0,
                bottom: 4,
                child: _buildProgressSlider(context),
              ),
            if (!_modalOpen)
              Positioned.fill(
                child: VideoOverlayActions(
                  commentCount: _commentCount,
                  video: video,
                  isFollowed: _isFollowed,
                  isLike: _isLike,
                  isFavorite: _isFavorite,
                  onUserTap: widget.onUserTap,
                  showModal: () async {
                    final mediaQuery = MediaQuery.of(context);
                    await _showModal(
                      mediaQuery.size.height - availableHeight * 0.4,
                    );
                  },
                  onFollowChanged: (v) async {
                    if (!mounted) return;

                    setState(() {
                      _isFollowed = v;
                    });

                    widget.onVideoInfoChange(video.copyWith(isFollow: v));
                  },

                  onLikeChanged: (v) async {
                    v
                        ? await videoService.likeVideo(video.id)
                        : await videoService.unlikeVideo(video.id);

                    setState(() => _isLike = v);

                    widget.onVideoInfoChange(
                      video.copyWith(
                        isLike: v,
                        likeCount: v
                            ? video.likeCount + 1
                            : video.likeCount - 1,
                      ),
                    );
                  },
                  onFavoriteChanged: (v) async {
                    v
                        ? await videoService.favoriteVideo(video.id)
                        : await videoService.unFavoriteVideo(video.id);

                    setState(() => _isFavorite = v);

                    widget.onVideoInfoChange(
                      video.copyWith(
                        isFavorite: v,
                        favoriteCount: v
                            ? video.favoriteCount + 1
                            : video.favoriteCount - 1,
                      ),
                    );
                  },
                  onHidden: (v) => v
                      ? widget.onHideComment?.call()
                      : widget.onShowComment?.call(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class MaterialWrapper extends StatelessWidget {
  final Widget child;
  const MaterialWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(color: Colors.transparent, child: child);
  }
}
