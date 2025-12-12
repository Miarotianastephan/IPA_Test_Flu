import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/video_info.dart';
import 'package:live_app/provider/api_provider.dart';
import 'package:live_app/provider/cureent_video_user_provider.dart';
import 'package:live_app/widgets/comment/comments_modal.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../api/services/video_service.dart';
import '../../page/comment_detail_page.dart';
import 'video_overlay_actions.dart';

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
  final VoidCallback? onShowComment;
  final VoidCallback? onHideComment;
  final Function(VideoInfo video) onVideoInfoChange;
  final ShortVideoItemController? controller;

  const ShortVideoItem({
    super.key,
    required this.videoInfo,
    required this.onUserTap,
    required this.onVideoInfoChange,
    this.onShowComment,
    this.onHideComment,
    this.controller,
  });

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

  bool useMediaKit = false;
  Player? _player;
  VideoController? _mediaKitController;

  VideoPlayerController? _videoController;

  bool _controlsVisible = true;
  Timer? _hideTimer;

  static const _fadeDuration = Duration(milliseconds: 250);
  static const _autoHideDelay = Duration(seconds: 3);
  late AnimationController _transitionController;

  late VideoService videoService;
  Future<bool> _isHarmonyOS() async {
    if (!Platform.isAndroid) return false;
    final info = await DeviceInfoPlugin().androidInfo;
    return info.manufacturer.toLowerCase() == "huawei";
  }

  @override
  void initState() {
    super.initState();

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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      videoService = ref.read(videoServiceProvider);
      ref.read(currentVideoUserProvider.notifier).state = widget.videoInfo.user;

      useMediaKit = await _isHarmonyOS();
      if (useMediaKit) {
        await _initializeMediaKit();
      }
    });

    if (!useMediaKit) {
      _videoController =
          VideoPlayerController.networkUrl(Uri.parse(widget.videoInfo.url))
            ..initialize().then((_) {
              setState(() {});
            });
    }

    _scheduleAutoHide();
  }

  Future<void> _initializeMediaKit() async {
    _player = Player();
    _mediaKitController = VideoController(_player!);

    try {
      await _player!.open(Media(widget.videoInfo.url), play: false);
    } catch (e) {
      debugPrint('Error initializing MediaKit: $e');
    }
  }

  void _showControls() {
    if (!_controlsVisible) setState(() => _controlsVisible = true);
    _scheduleAutoHide();
  }

  void _hideControls() {
    if (_controlsVisible) setState(() => _controlsVisible = false);
    _hideTimer?.cancel();
  }

  void _toggleControls() {
    _controlsVisible ? _hideControls() : _showControls();
  }

  void _scheduleAutoHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(_autoHideDelay, () {
      if (!_modalOpen) _hideControls();
    });
  }

  Future<void> _showModal(double height) async {
    setState(() {
      _modalOpen = true;
      _controlsVisible = false;
    });

    _hideTimer?.cancel();
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
                  _showControls();
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
                  _showControls();
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
    _hideTimer?.cancel();
    _transitionController.dispose();

    if (useMediaKit) {
      _player?.pause();
      _player?.dispose();
    } else {
      _videoController?.pause();
      _videoController?.dispose();
    }

    super.dispose();
  }

  Widget _circleButton(IconData icon, {double size = 30, double padding = 20}) {
    return Container(
      width: size + padding,
      height: size + padding,
      decoration: const BoxDecoration(
        color: Color.fromARGB(95, 0, 0, 0),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: size),
    );
  }

  @override
  Widget build(BuildContext context) {
    final video = widget.videoInfo;
    final mediaQuery = MediaQuery.of(context);
    double availableHeight = 0;
    bool isPlaying = useMediaKit
        ? _player?.state.playing ?? false
        : (_videoController != null && _videoController!.value.isInitialized
              ? _videoController!.value.isPlaying
              : false);

    return PopScope(
      canPop: !_modalOpen,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && _modalOpen) {
          await _transitionController.reverse();
          setState(() {
            _modalOpen = false;
            _showControls();
          });
          widget.onHideComment?.call();
        }
      },
      child: VisibilityDetector(
        key: Key(video.id.toString()),
        onVisibilityChanged: (info) {
          if (info.visibleFraction == 0) {
            if (useMediaKit) {
              _player?.pause();
            } else {
              _videoController?.pause();
            }
          } else if (info.visibleFraction > 0.8) {
            if (useMediaKit) {
              _player?.play();
            } else {
              _videoController?.play();
            }
          }
        },
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (_, constraints) {
                availableHeight = constraints.maxHeight;
                return Column(
                  children: [
                    SizedBox(
                      height:
                          mediaQuery.padding.top * _transitionController.value,
                    ),

                    Expanded(
                      child: useMediaKit
                          ? Video(
                              controller: _mediaKitController!,
                              fit: video.type == 2
                                  ? BoxFit.contain
                                  : BoxFit.cover,
                              controls: null,
                            )
                          : SizedBox(
                              width: double.infinity,
                              child: VideoPlayer(_videoController!),
                            ),
                    ),

                    SizedBox(
                      height:
                          availableHeight * 0.6 * _transitionController.value,
                    ),
                  ],
                );
              },
            ),

            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  _toggleControls();

                  if (useMediaKit) {
                    if (_player!.state.playing) {
                      _player!.pause();
                      setState(() => isPlaying = false);
                    } else {
                      _player!.play();
                      setState(() => isPlaying = true);
                    }
                  } else {
                    if (_videoController!.value.isPlaying) {
                      _videoController!.pause();
                      setState(() => isPlaying = false);
                    } else {
                      _videoController!.play();
                      setState(() => isPlaying = true);
                    }
                  }
                },
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _controlsVisible ? 1 : 0,
                    duration: _fadeDuration,
                    child: IgnorePointer(
                      ignoring: !_controlsVisible,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _showControls();
                              if (useMediaKit) {
                                final pos = _player!.state.position;
                                _player!.seek(pos - Duration(seconds: 10));
                              } else {
                                final pos = _videoController!.value.position;
                                _videoController!.seekTo(
                                  pos - Duration(seconds: 10),
                                );
                              }
                            },
                            child: _circleButton(Icons.replay_10),
                          ),
                          const SizedBox(width: 15),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isPlaying = !isPlaying;
                              });

                              if (useMediaKit) {
                                if (isPlaying) {
                                  _player?.play();
                                } else {
                                  _player?.pause();
                                }
                              } else {
                                if (_videoController != null &&
                                    _videoController!.value.isInitialized) {
                                  if (isPlaying) {
                                    _videoController!.play();
                                  } else {
                                    _videoController!.pause();
                                  }
                                }
                              }
                            },
                            child: _circleButton(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              size: 50,
                              padding: 30,
                            ),
                          ),

                          const SizedBox(width: 15),
                          GestureDetector(
                            onTap: () {
                              _showControls();
                              if (useMediaKit) {
                                final pos = _player!.state.position;
                                _player!.seek(pos + Duration(seconds: 10));
                              } else {
                                final pos = _videoController!.value.position;
                                _videoController!.seekTo(
                                  pos + Duration(seconds: 10),
                                );
                              }
                            },
                            child: _circleButton(Icons.forward_10),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            useMediaKit
                ? Positioned(
                    left: 0,
                    right: 0,
                    bottom: 4,
                    child: StreamBuilder<Duration>(
                      stream: _player!.stream.position,
                      builder: (context, snapshot) {
                        final position = snapshot.data ?? Duration.zero;
                        final duration = _player!.state.duration;

                        final progress = (duration.inMilliseconds == 0)
                            ? 0.0
                            : position.inMilliseconds / duration.inMilliseconds;

                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTapDown: (details) {
                            _showControls();
                            final box = context.findRenderObject() as RenderBox;
                            final dx = box
                                .globalToLocal(details.globalPosition)
                                .dx;
                            final x = (dx / box.size.width).clamp(0.0, 1.0);
                            _player!.seek(duration * x);
                          },
                          onHorizontalDragUpdate: (details) {
                            _showControls();
                            final box = context.findRenderObject() as RenderBox;
                            final dx = box
                                .globalToLocal(details.globalPosition)
                                .dx;
                            final x = (dx / box.size.width).clamp(0.0, 1.0);
                            _player!.seek(duration * x);
                          },
                          child: SizedBox(
                            height: 6,
                            child: MaterialWrapper(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 4,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 6,
                                  ),
                                  overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 12,
                                  ),
                                  activeTrackColor: Colors.white,
                                  inactiveTrackColor: Colors.white30,
                                  thumbColor: Colors.white,
                                  overlayColor: Colors.white24,
                                ),
                                child: Slider(
                                  value: progress.isNaN
                                      ? 0.0
                                      : progress.clamp(0.0, 1.0),
                                  onChanged: (value) {
                                    _showControls();
                                    _player!.seek(duration * value);
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Positioned(
                    left: 0,
                    right: 0,
                    bottom: 4,
                    child: ValueListenableBuilder<VideoPlayerValue>(
                      valueListenable: _videoController!,
                      builder: (context, value, _) {
                        final position = value.position;
                        final duration = value.duration;

                        final progress = (duration.inMilliseconds == 0)
                            ? 0.0
                            : position.inMilliseconds / duration.inMilliseconds;

                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTapDown: (details) {
                            _showControls();
                            final box = context.findRenderObject() as RenderBox;
                            final dx = box
                                .globalToLocal(details.globalPosition)
                                .dx;
                            final x = (dx / box.size.width).clamp(0.0, 1.0);
                            final seekPos = Duration(
                              milliseconds: (duration.inMilliseconds * x)
                                  .round(),
                            );
                            _videoController!.seekTo(seekPos);
                          },
                          onHorizontalDragUpdate: (details) {
                            _showControls();
                            final box = context.findRenderObject() as RenderBox;
                            final dx = box
                                .globalToLocal(details.globalPosition)
                                .dx;
                            final x = (dx / box.size.width).clamp(0.0, 1.0);
                            final seekPos = Duration(
                              milliseconds: (duration.inMilliseconds * x)
                                  .round(),
                            );
                            _videoController!.seekTo(seekPos);
                          },
                          child: SizedBox(
                            height: 6,
                            child: MaterialWrapper(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 4,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 6,
                                  ),
                                  overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 12,
                                  ),
                                  activeTrackColor: Colors.white,
                                  inactiveTrackColor: Colors.white30,
                                  thumbColor: Colors.white,
                                  overlayColor: Colors.white24,
                                ),
                                child: Slider(
                                  value: progress.isNaN
                                      ? 0.0
                                      : progress.clamp(0.0, 1.0),
                                  onChanged: (value) {
                                    _showControls();
                                    final seekPos = Duration(
                                      milliseconds:
                                          (duration.inMilliseconds * value)
                                              .round(),
                                    );
                                    _videoController!.seekTo(seekPos);
                                  },
                                ),
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
                showModal: () =>
                    _showModal(mediaQuery.size.height - availableHeight * 0.4),
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
                      likeCount: v ? video.likeCount + 1 : video.likeCount - 1,
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
