import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/main.dart';
import 'package:live_app/models/video_comment.dart';
import 'package:live_app/models/video_info.dart';
import 'package:live_app/provider/api_provider.dart';
import 'package:live_app/provider/behavior_tracker_provider.dart';
import 'package:live_app/provider/cumulative_watch_time_provider.dart';
import 'package:live_app/provider/cureent_video_user_provider.dart';
import 'package:live_app/provider/current_tab_provider.dart';
import 'package:live_app/provider/current_video_provider.dart';
import 'package:live_app/provider/expired_preview_provider.dart';
import 'package:live_app/provider/my_user_provider.dart';
import 'package:live_app/provider/video_position_provider.dart';
import 'package:live_app/provider/web_video_mute_provider.dart';
import 'package:live_app/utils/utils.dart';
import 'package:live_app/widgets/comment/comments_modal.dart';
import 'package:live_app/widgets/payment/time_unlock_popup.dart';
import 'package:live_app/widgets/video/preview_limited_overlay.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../api/services/video_service.dart';
import '../../page/comment_detail_page.dart';
import '../../provider/app_config_provider.dart';
import '../../provider/expired_preview_popup_provider.dart';
import '../../provider/purchased_contents_provider.dart';
import '../../utils/app_lang_version_utils.dart';
import '../encrypted_image.dart';
import 'bw_progress.dart';
import 'deposit_promo_overlay.dart';
import 'short_video_item_stub.dart'
    if (dart.library.io) 'short_video_item_mobile_impl.dart'
    if (dart.library.html) 'short_video_item_web_impl.dart'
    as platform_impl;
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
  VoidCallback? _pauseCallback;
  VoidCallback? _playCallback;

  void bindPause(VoidCallback pause) {
    _pauseCallback = pause;
  }

  void bindPlay(VoidCallback play) {
    _playCallback = play;
  }

  void pause() {
    _pauseCallback?.call();
  }

  void play() {
    _playCallback?.call();
  }
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
  final bool isFirstItem;
  final String pageKey;

  const ShortVideoItem({
    super.key,
    required this.videoInfo,
    required this.onUserTap,
    required this.onVideoInfoChange,
    required this.pageKey,
    this.onInitialized,
    this.onShowComment,
    this.onHideComment,
    this.onReset,
    this.onBufferingChanged,
    this.controller,
    required this.isFirstItem,
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
  double _lastVisibleFraction = 0;

  late AnimationController _transitionController;

  double _maxAvailableHeight = 0;
  bool _isKeyboardOpen = false;
  bool _isPreviewLimited = false;

  bool _hasDeposit = false;

  bool _forceReload = false;

  late VideoService videoService;
  bool _manuallyPaused = false;
  VoidCallback? _controllerListener;
  int? _lastPlaybackPositionMsForWatchTime;
  bool _ignoreNextPlaybackDeltaForWatchTime = false;

  Future<void> _checkUserGiftStatus() async {
    final result = await ref.read(userProvider.notifier).checkUserGiftReceive();
    if (result != null && mounted) {
      setState(() {
        _hasDeposit = result.amount > 0;
        _forceReload = result.forceReload > 0;
      });
    }
  }

  platform_impl.PlatformVideoPlayer? _platformPlayer;

  @override
  void didUpdateWidget(ShortVideoItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller != null && _controllerListener != null) {
        oldWidget.controller!.removeListener(_controllerListener!);
      }
      _attachControllerListener();
    }

    if (widget.videoInfo.id != oldWidget.videoInfo.id ||
        widget.videoInfo.url != oldWidget.videoInfo.url) {
      _showVideo = false;
      _hasCalledOnInitialized = false;
      _manuallyPaused = false;
      _lastPlaybackPositionMsForWatchTime = null;
      _ignoreNextPlaybackDeltaForWatchTime = false;
      final v = widget.videoInfo;
      _isFollowed = v.isFollow;
      _isLike = v.isLike;
      _isFavorite = v.isFavorite;
      _commentCount = v.commentCount;

      widget.onReset?.call();
      _disposePlayer();
      _initializeVideo();
    }
  }

  void _disposePlayer() {
    _unbindPlayerStateListeners();
    _platformPlayer?.dispose();
    _platformPlayer = null;
    _lastPlaybackPositionMsForWatchTime = null;
    _ignoreNextPlaybackDeltaForWatchTime = false;
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

    _attachControllerListener();

    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _initializeVideo();
    _checkUserGiftStatus();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupMuteListener();
      _setupWatchTimeListener();
    });
  }

  void _setupMuteListener() {
    ref.listenManual(webVideoMuteProvider, (previous, next) {
      if (previous?.isMuted != next.isMuted) {
        _platformPlayer?.setMuted(next.isMuted);
      }
    });
  }

  void _setupWatchTimeListener() {
    ref.listenManual(cumulativeWatchTimeProvider, (previous, next) async {
      if (!mounted) return;
      final hadTime = (previous?.remainingSeconds ?? 0) > 0;
      final hasTime = next.remainingSeconds > 0;

      if (!hadTime && hasTime && _isPreviewLimited) {
        ref
            .read(expiredPreviewProvider.notifier)
            .clearExpired(widget.videoInfo.id);
        setState(() {
          _isPreviewLimited = false;
        });
        _play();
        ref
            .read(cumulativeWatchTimeProvider.notifier)
            .startTracking(videoId: widget.videoInfo.id);
      }
    });
  }

  Future<void> _initializeVideo() async {
    _platformPlayer = platform_impl.createPlatformVideoPlayer(
      onLoaded: () {
        if (!mounted || _showVideo) return;
        setState(() {
          _showVideo = true;
        });
      },
      onPlay: () {
        ref.trackVideoWatch();
      },
      onPause: () {},
      onMute: () {
        ref.read(webVideoMuteProvider.notifier).setMuted(true);
      },
      onWatchPercentReached: (watchDuration, videoDuration) {
        ref
            .read(userProvider.notifier)
            .userInterest(
              videoId: widget.videoInfo.id,
              watchDuration: watchDuration,
              videoDuration: videoDuration,
            );
      },
    );

    final playbackInfo = await videoService.playVideo(
      videoUrl: widget.videoInfo.url,
      key: widget.videoInfo.encryptionKey ?? 'fsjkey',
    );

    await _platformPlayer!.initialize(
      playbackInfo.m3u8Content,
      widget.videoInfo.url,
      widget.videoInfo.encryptionKey ?? 'fsjkey',
      videoId: widget.videoInfo.id,
    );
    widget.controller?.bindPause(() => _platformPlayer?.pause());
    widget.controller?.bindPlay(_play);
    if (mounted) {
      _syncMuteState();
      _bindPlayerStateListeners();
    }
  }

  void _bindPlayerStateListeners() {
    if (_platformPlayer == null) return;

    _platformPlayer!.positionListenable.addListener(_syncVideoPosition);

    // 初始化状态变化
    _platformPlayer!.isInitializedListenable.addListener(_notifyBuffering);

    // buffering 状态变化
    _platformPlayer!.isBufferingListenable.addListener(_notifyBuffering);

    _platformPlayer!.isPlayingListenable.addListener(_onPlayingStateChanged);

    //立刻同步一次当前状态
    _notifyBuffering();
  }

  void _onPlayingStateChanged() {
    if (!mounted || _platformPlayer == null) return;

    final video = widget.videoInfo;
    final isPaid =
        video.price > 0 &&
        !video.isBought &&
        !ref.hasPermission(Permission.accessShortFree);
    if (!isPaid) return;

    final isPlaying = _platformPlayer!.isPlayingListenable.value;
    final notifier = ref.read(cumulativeWatchTimeProvider.notifier);

    if (isPlaying) {
      final watchTimeState = ref.read(cumulativeWatchTimeProvider);
      if (watchTimeState.remainingSeconds > 0) {
        _lastPlaybackPositionMsForWatchTime =
            _platformPlayer!.positionListenable.value.inMilliseconds;
        notifier.startTracking(videoId: video.id);
      }
    } else {
      _lastPlaybackPositionMsForWatchTime = null;
      notifier.stopTracking(videoId: video.id);
    }
  }

  void _syncVideoPosition() {
    if (!mounted || _platformPlayer == null) return;
    final currentPosition = _platformPlayer!.positionListenable.value;
    final posSeconds = currentPosition.inSeconds.toDouble();
    ref.read(videoPositionProvider.notifier).state = posSeconds;
    _syncWatchTimeByPlayback(currentPosition);
  }

  void _syncWatchTimeByPlayback(Duration currentPosition) {
    if (!mounted || _platformPlayer == null) return;

    final video = widget.videoInfo;
    final isPaid =
        video.price > 0 &&
        !video.isBought &&
        !ref.hasPermission(Permission.accessShortFree);
    if (!isPaid) return;

    final watchTimeState = ref.read(cumulativeWatchTimeProvider);
    if (watchTimeState.remainingSeconds <= 0) {
      _lastPlaybackPositionMsForWatchTime = null;
      return;
    }

    final player = _platformPlayer!;
    final isActuallyPlaying =
        player.isInitializedListenable.value &&
        player.isPlayingListenable.value &&
        !player.isBufferingListenable.value;
    if (!isActuallyPlaying) {
      _lastPlaybackPositionMsForWatchTime = currentPosition.inMilliseconds;
      return;
    }

    final notifier = ref.read(cumulativeWatchTimeProvider.notifier);
    notifier.startTracking(videoId: video.id);

    final currentMs = currentPosition.inMilliseconds;
    final previousMs = _lastPlaybackPositionMsForWatchTime;
    _lastPlaybackPositionMsForWatchTime = currentMs;

    if (previousMs == null) return;
    if (_ignoreNextPlaybackDeltaForWatchTime) {
      _ignoreNextPlaybackDeltaForWatchTime = false;
      return;
    }

    final deltaMs = currentMs - previousMs;
    if (deltaMs <= 0) return;

    notifier.addPlaybackDuration(
      duration: Duration(milliseconds: deltaMs),
      videoId: video.id,
    );
  }

  void _notifyBuffering() {
    if (!mounted || _platformPlayer == null) return;

    final initialized = _platformPlayer!.isInitializedListenable.value;
    final buffering = _platformPlayer!.isBufferingListenable.value;

    if (!initialized) {
      widget.onBufferingChanged?.call(true);
    } else {
      widget.onBufferingChanged?.call(buffering);
    }
  }

  void _unbindPlayerStateListeners() {
    if (_platformPlayer == null) return;

    _platformPlayer!.positionListenable.removeListener(_syncVideoPosition);
    _platformPlayer!.isInitializedListenable.removeListener(_notifyBuffering);
    _platformPlayer!.isBufferingListenable.removeListener(_notifyBuffering);
    _platformPlayer!.isPlayingListenable.removeListener(_onPlayingStateChanged);
  }

  void _syncMuteState() {
    if (_platformPlayer == null) return;
    final muteState = ref.read(webVideoMuteProvider);
    _platformPlayer!.setMuted(muteState.isMuted);
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
              onCommentTap: (VideoComment comment) async {
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
    if (widget.controller != null && _controllerListener != null) {
      widget.controller!.removeListener(_controllerListener!);
    }
    _transitionController.dispose();
    _disposePlayer();
    super.dispose();
  }

  void _attachControllerListener() {
    final controller = widget.controller;
    if (controller == null) return;

    _controllerListener = () {
      if (!mounted) return;
      setState(() {
        _isFollowed = controller.isFollowed ?? _isFollowed;
        _isLike = controller.isLike ?? _isLike;
        _isFavorite = controller.isFavorite ?? _isFavorite;
        _commentCount = controller.commentCount ?? _commentCount;
      });
    };
    controller.addListener(_controllerListener!);
  }

  int get _previewDurationSeconds {
    final appConfig = ref.read(appConfigProvider);
    return appConfig.data?.paymentFeatureFlags?.previewDurationSeconds ?? 16;
  }

  bool _shouldBlockPlayback() {
    final previewDuration = _previewDurationSeconds;
    if (ref.hasPermission(Permission.accessShortFree)) {
      return false;
    }

    final videoPrice = widget.videoInfo.price;
    if (videoPrice == 0) {
      return false;
    }

    final watchTimeState = ref.read(cumulativeWatchTimeProvider);
    if (watchTimeState.remainingSeconds > 0) {
      return false;
    }

    if (_platformPlayer != null &&
        _platformPlayer!.isInitializedListenable.value) {
      final currentPosition = _platformPlayer!.positionListenable.value;
      if (currentPosition.inSeconds < previewDuration) {
        return false;
      } else {
        return true;
      }
    }

    return watchTimeState.shouldBlockPlayback;
  }

  void _play() {
    if (!mounted || _isPreviewLimited) return;
    final videoId = widget.videoInfo.id;
    if (ref.read(expiredPreviewProvider.notifier).isExpired(videoId)) {
      if (!_isPreviewLimited) {
        setState(() {
          _isPreviewLimited = true;
        });
      }
      return;
    }
    _platformPlayer?.play();
  }

  void _pause() {
    _platformPlayer?.pause();
  }

  void _seekTo(Duration position) {
    _ignoreNextPlaybackDeltaForWatchTime = true;
    _lastPlaybackPositionMsForWatchTime = position.inMilliseconds;
    _platformPlayer?.seekTo(position);
  }

  void _handleTimeUnlockSuccess() {
    if (!mounted) return;

    ref.read(expiredPreviewProvider.notifier).clearExpired(widget.videoInfo.id);
    ref
        .read(purchasedContentProvider.notifier)
        .markAsPurchased('video', widget.videoInfo.id);

    widget.onVideoInfoChange(widget.videoInfo.copyWith(isBought: true));

    setState(() {
      _isPreviewLimited = false;
      _manuallyPaused = false;
    });

    _play();
  }

  Widget _buildProgressSlider(BuildContext context) {
    if (_platformPlayer == null) return const SizedBox.shrink();

    return ValueListenableBuilder<Duration>(
      valueListenable: _platformPlayer!.positionListenable,
      builder: (_, position, _) {
        final duration = Duration(
          milliseconds: (widget.videoInfo.duration).toInt(),
        );
        final progress = duration.inMilliseconds == 0
            ? 0.0
            : position.inMilliseconds / duration.inMilliseconds;
        final isPaidVideo =
            widget.videoInfo.price > 0 &&
            !widget.videoInfo.isBought &&
            !ref.hasPermission(Permission.accessShortFree);
        return _buildSlider(context, position, duration, progress, isPaidVideo);
      },
    );
  }

  void _autoPlayIfVisible() {
    if (!mounted ||
        _platformPlayer!.isPlayingListenable.value ||
        _shouldBlockPlayback()) {
      return;
    }
    if (!kIsWeb && _lastVisibleFraction > 0.65) {
      _play();
    }
  }

  Widget _buildSlider(
    BuildContext context,
    Duration position,
    Duration duration,
    double progress,
    bool isPaidVideo,
  ) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: GestureDetector(
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
            child: Material(
              color: Colors.transparent,
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
                  value: progress.isNaN ? 0.0 : progress.clamp(0.0, 1.0),
                  onChanged: (value) {
                    _seekTo(duration * value);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showUnlockPopup() {}

  @override
  Widget build(BuildContext context) {
    final video = widget.videoInfo;
    final showPricing = ref.read(appConfigProvider).data?.showPricing ?? false;

    double availableHeight = 0;

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
                color: Colors.transparent,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: EncryptedImage(
                        url: video.cover,
                        fit: video.type == 2 ? BoxFit.contain : BoxFit.cover,
                        errorWidget: const Icon(Icons.broken_image, size: 40),
                      ),
                    ),

                    Positioned.fill(
                      child: ValueListenableBuilder<bool>(
                        valueListenable:
                            _platformPlayer!.isInitializedListenable,
                        builder: (_, ready, _) {
                          if (!ready) return const SizedBox.shrink();

                          if (!_hasCalledOnInitialized) {
                            _hasCalledOnInitialized = true;
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              widget.onInitialized?.call();
                              _autoPlayIfVisible();
                            });
                          }

                          return VisibilityDetector(
                            key: Key('visibility_${video.id}_$hashCode'),
                            onVisibilityChanged: (info) {
                              _lastVisibleFraction = info.visibleFraction;

                              final player = _platformPlayer;
                              if (!mounted || player == null) return;

                              final isPlaying =
                                  player.isPlayingListenable.value;

                              if (info.visibleFraction == 0) {
                                _pause();
                                ref
                                    .read(cumulativeWatchTimeProvider.notifier)
                                    .stopTracking(videoId: video.id);
                              } else if (info.visibleFraction > 0.65) {
                                ref
                                        .read(currentVideoUserProvider.notifier)
                                        .state =
                                    video.user;
                                ref.read(currentVideoProvider.notifier).state =
                                    video;

                                if (!isPlaying) {
                                  _play();
                                }
                              }
                            },
                            child: AnimatedOpacity(
                              opacity: _showVideo ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 250),
                              child: _platformPlayer!.buildVideoWidget(
                                fit: video.type == 2
                                    ? BoxFit.contain
                                    : BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    Positioned.fill(
                      child: IgnorePointer(
                        child: Center(
                          child: ValueListenableBuilder<bool>(
                            valueListenable:
                                _platformPlayer!.isBufferingListenable,
                            builder: (_, isBuffering, _) {
                              return isBuffering
                                  ? const BWProgress()
                                  : const SizedBox.shrink();
                            },
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
              onTap: () async {
                if (_isPreviewLimited) {
                  if (_hasDeposit) {
                    await _showTimeUnlockPopup();
                  }
                  return;
                }
                final isPlaying = _platformPlayer!.isPlayingListenable.value;

                if (isPlaying) {
                  _manuallyPaused = true;
                  _pause();
                } else {
                  _play();
                }
              },
              child: Center(
                child: ValueListenableBuilder<bool>(
                  valueListenable: _platformPlayer!.isPlayingListenable,
                  builder: (_, isPlaying, _) {
                    return AnimatedOpacity(
                      opacity: (!_manuallyPaused || isPlaying) ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white.withValues(alpha: 0.6),
                        size: 128,
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
            height: 200,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragUpdate: (details) {},
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 5.0,
            child: _buildProgressSlider(context),
          ),
          Positioned.fill(
            child: Visibility(
              visible: !_modalOpen,
              maintainState: true,
              child: VideoOverlayActions(
                commentCount: _commentCount,
                video: video,
                isFollowed: _isFollowed,
                isLike: _isLike,
                isFavorite: _isFavorite,
                isPlayingListenable: _platformPlayer?.isPlayingListenable,
                positionListenable: _platformPlayer?.positionListenable,
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

                  if (v) {
                    ref.trackLike();
                  }

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
                onPreviewExpired: () async {
                  if (!mounted) return;
                  _pause();

                  if (_forceReload) {
                    restartApp();
                    return;
                  }

                  final isPurchased = ref.watch(
                    isContentPurchasedProvider(('video', video.id)),
                  );

                  final hasShown = ref
                      .read(previewPopupTrackerProvider.notifier)
                      .isShown(widget.pageKey, video.id);

                  if (!isPurchased && !hasShown) {
                    ref
                        .read(previewPopupTrackerProvider.notifier)
                        .markShown(widget.pageKey, video.id);

                    setState(() {
                      _isPreviewLimited = true;
                    });

                    await _showTimeUnlockPopup();
                  }
                },
                onPreviewUnlocked: () {
                  if (!mounted) return;
                  ref
                      .read(expiredPreviewProvider.notifier)
                      .clearExpired(widget.videoInfo.id);
                  setState(() {
                    _isPreviewLimited = false;
                  });
                  _play();
                },
              ),
            ),
          ),
          if (_isPreviewLimited && video.price > 0)
            if ((_hasDeposit ||
                    AppLangVersionUtils.isCn() ||
                    AppLangVersionUtils.isTk()) &&
                showPricing)
              PreviewLimitedOverlay(onUnlockPressed: _showTimeUnlockPopup)
            else
              DepositPromoOverlay(
                onDepositPressed: () =>
                    (AppLangVersionUtils.isCn() || AppLangVersionUtils.isTk())
                    ? null
                    : _navigateToGame(),
              ),
        ],
      ),
    );
  }

  Future<bool> _showTimeUnlockPopup() async {
    final success = await TimeUnlockPopup.show(
      context: context,
      videoInfo: widget.videoInfo,
    );

    if (success) {
      _handleTimeUnlockSuccess();
    }

    return success;
  }

  void _navigateToGame() {
    final gameTabIndex = ref.read(gameTabIndexProvider);
    if (gameTabIndex >= 0) {
      ref.read(switchTabRequestProvider.notifier).state = gameTabIndex;
    }
  }
}
