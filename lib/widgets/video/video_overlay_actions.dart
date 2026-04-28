import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/database/download_database.dart';
import 'package:live_app/provider/app_config_provider.dart';
import 'package:live_app/provider/cumulative_watch_time_provider.dart';
import 'package:live_app/provider/download_video_provider.dart';
import 'package:live_app/provider/expired_preview_provider.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/provider/user_follow_provider.dart';
import 'package:live_app/utils/text_util.dart';
import 'package:live_app/utils/utils.dart';
import 'package:live_app/widgets/download_button.dart';

import '../../models/video_info.dart';
import '../Animation/follow_splash_animation.dart';
import '../encrypted_image.dart';
import '../vip_badge.dart';
import 'purchased_badge.dart';

class VideoOverlayActions extends ConsumerStatefulWidget {
  final VideoInfo video;
  final bool isFollowed;
  final bool isLike;
  final bool isFavorite;
  final int commentCount;
  final Future<void> Function() showModal;
  final Future<void> Function(bool) onFollowChanged;
  final Future<void> Function(bool) onLikeChanged;
  final Future<void> Function(bool) onFavoriteChanged; // 新增收藏回调
  final void Function(VideoInfo) onUserTap;
  final void Function(bool) onHidden;
  final VoidCallback? onCommentAdded;
  final ValueListenable<bool>? isPlayingListenable;
  final ValueListenable<Duration>? positionListenable;
  final VoidCallback? onPreviewExpired;
  final VoidCallback? onPreviewUnlocked;

  const VideoOverlayActions({
    super.key,
    required this.video,
    required this.isFollowed,
    required this.isLike,
    required this.isFavorite,
    required this.commentCount,
    required this.showModal,
    required this.onFollowChanged,
    required this.onLikeChanged,
    required this.onFavoriteChanged,
    required this.onUserTap,
    required this.onHidden,
    this.onCommentAdded,
    this.isPlayingListenable,
    this.positionListenable,
    this.onPreviewExpired,
    this.onPreviewUnlocked,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _VideoOverlayActionsState();
}

class _VideoOverlayActionsState extends ConsumerState<VideoOverlayActions>
    with SingleTickerProviderStateMixin {
  bool _showActions = true;

  late AnimationController _likeController;
  late Animation<double> _scaleAnimation;
  final GlobalKey _followBtnKey = GlobalKey();
  OverlayEntry? _splashEntry;
  int _favoriteCount = 0;
  int _likeCount = 0;
  int _commentCount = 0;
  bool isTapLike = false;

  int _previewCountdown = 0;
  bool _previewExpired = false;
  int? _previewCountdownStartPositionMs;
  int _maxPreviewConsumedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _favoriteCount = widget.video.favoriteCount;
    _likeCount = widget.video.likeCount;
    _commentCount = widget.commentCount;
    _likeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.2,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _likeController, curve: Curves.easeOut));

    _initPreviewCountdown();
    widget.isPlayingListenable?.addListener(_onPlayingChanged);
    widget.positionListenable?.addListener(_onPositionChanged);

    // Listen for watch time running out to start preview countdown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(cumulativeWatchTimeProvider, (previous, next) {
        _onWatchTimeChanged();
      });
    });
  }

  bool get _isBasePaidVideo =>
      widget.video.price > 0 &&
      !widget.video.isBought &&
      !ref.hasPermission(Permission.accessShortFree);

  int get _previewDurationSeconds {
    final appConfig = ref.read(appConfigProvider);
    return appConfig.data?.paymentFeatureFlags?.previewDurationSeconds ?? 10;
  }

  void _initPreviewCountdown() {
    if (!_isBasePaidVideo) return;

    final isAlreadyExpired =
        ref.read(expiredPreviewProvider.notifier).isExpired(widget.video.id);
    if (isAlreadyExpired) {
      _previewExpired = true;
      _previewCountdown = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onPreviewExpired?.call();
      });
      return;
    }

    final watchTimeState = ref.read(cumulativeWatchTimeProvider);
    if (watchTimeState.remainingSeconds > 0) return;

    _initPreviewSeconds();
  }

  void _initPreviewSeconds() {
    _previewCountdown = _previewDurationSeconds;
    _previewCountdownStartPositionMs = null;
    _maxPreviewConsumedSeconds = 0;
  }

  void _onWatchTimeChanged() {
    if (!_isBasePaidVideo || _previewExpired) return;
    final watchTimeState = ref.read(cumulativeWatchTimeProvider);

    if (watchTimeState.remainingSeconds > 0) {
      _previewCountdownStartPositionMs = null;
      return;
    }

    if (_previewCountdown == 0) {
      _initPreviewSeconds();
    }
    _syncPreviewCountdownFromPosition();
  }

  void _onPlayingChanged() {
    if (_previewExpired || !_isBasePaidVideo) return;
    _syncPreviewCountdownFromPosition();
  }

  void _onPositionChanged() {
    if (_previewExpired || !_isBasePaidVideo) return;
    _syncPreviewCountdownFromPosition();
  }

  void _syncPreviewCountdownFromPosition() {
    final watchTimeState = ref.read(cumulativeWatchTimeProvider);
    if (watchTimeState.remainingSeconds > 0 || _previewExpired) {
      _previewCountdownStartPositionMs = null;
      return;
    }

    final isPlaying = widget.isPlayingListenable?.value ?? false;
    if (!isPlaying) return;

    final position = widget.positionListenable?.value;
    if (position == null) return;

    if (_previewCountdown == 0) {
      _initPreviewSeconds();
    }

    final currentPositionMs = position.inMilliseconds;
    _previewCountdownStartPositionMs ??= currentPositionMs;

    var playedMs = currentPositionMs - _previewCountdownStartPositionMs!;
    if (playedMs < 0) {
      _previewCountdownStartPositionMs = currentPositionMs;
      playedMs = 0;
    }

    final consumedSeconds = playedMs ~/ 1000;
    if (consumedSeconds > _maxPreviewConsumedSeconds) {
      _maxPreviewConsumedSeconds = consumedSeconds;
    }

    final nextCountdown = (_previewDurationSeconds - _maxPreviewConsumedSeconds)
        .clamp(0, _previewDurationSeconds)
        .toInt();

    if (nextCountdown != _previewCountdown) {
      setState(() {
        _previewCountdown = nextCountdown;
      });
    }

    if (nextCountdown <= 0) {
      _markPreviewExpired();
    }
  }

  void _markPreviewExpired() {
    if (_previewExpired) return;
    setState(() {
      _previewCountdown = 0;
      _previewExpired = true;
    });
    ref.read(expiredPreviewProvider.notifier).markExpired(widget.video.id);
    widget.onPreviewExpired?.call();
  }

  @override
  void didUpdateWidget(VideoOverlayActions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.commentCount != widget.commentCount) {
      setState(() {
        _commentCount = widget.commentCount;
      });
    }
    if (oldWidget.isPlayingListenable != widget.isPlayingListenable) {
      oldWidget.isPlayingListenable?.removeListener(_onPlayingChanged);
      widget.isPlayingListenable?.addListener(_onPlayingChanged);
    }
    if (oldWidget.positionListenable != widget.positionListenable) {
      oldWidget.positionListenable?.removeListener(_onPositionChanged);
      widget.positionListenable?.addListener(_onPositionChanged);
    }
  }

  void incrementCommentCount() {
    setState(() {
      _commentCount++;
    });
  }

  @override
  void dispose() {
    widget.isPlayingListenable?.removeListener(_onPlayingChanged);
    widget.positionListenable?.removeListener(_onPositionChanged);
    _splashEntry?.remove();
    _splashEntry = null;
    _likeController.dispose();
    super.dispose();
  }

  Widget _buildAction({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required int count,
    required bool showText,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Icon(icon, color: color, size: 36),
        ),
        if (showText)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              count.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
      ],
    );
  }

  void _showLikeSplash(Offset position) {
    _splashEntry?.remove();
    setState(() {
      isTapLike = true;
    });
    _splashEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx - 40,
        top: position.dy - 40,
        child: AnimatedBuilder(
          animation: _likeController,
          builder: (context, child) {
            return Transform.scale(scale: _scaleAnimation.value, child: child);
          },
          child: const Icon(Icons.favorite, size: 80, color: Colors.red),
        ),
      ),
    );

    Overlay.of(context).insert(_splashEntry!);

    _likeController.forward(from: 0).whenComplete(() {
      _splashEntry?.remove();
      _splashEntry = null;
      setState(() {
        isTapLike = false;
      });
    });
  }

  void _showFollowSplash() {
    final overlay = Overlay.of(context);
    final renderBox =
        _followBtnKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _splashEntry = OverlayEntry(
      builder: (ctx) => Stack(
        children: [
          Positioned(
            left: offset.dx + size.width / 2 - 20, // 居中放置，假设动画大小约40
            top: offset.dy + size.height / 2 - 20,
            child: IgnorePointer(
              child: FollowSplashAnimation(
                onFinish: () {
                  _splashEntry?.remove();
                  _splashEntry = null;
                },
              ),
            ),
          ),
        ],
      ),
    );
    overlay.insert(_splashEntry!);
  }

  String _formatSeconds(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final watchTimeState = ref.watch(cumulativeWatchTimeProvider);
    final hasWatchTime = watchTimeState.remainingSeconds > 0;
    final isPaid = widget.video.price > 0 &&
        !widget.video.isBought &&
        !ref.hasPermission(Permission.accessShortFree);

    return Stack(
      children: [
        // 底部文字
        if (_showActions)
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 15, bottom: 20, right: 80),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget.video.user.nickname != null
                              ? "@${widget.video.user.nickname}"
                              : "",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      VipBadge(vip: widget.video.user.vip, size: 16),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ExpandableText(
                    widget.video.title.isNotEmpty ? widget.video.title : "",
                  ),
                  //duration
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.play_circle_outline,
                        color: Colors.white70,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formatDuration(widget.video.duration),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

        // 右侧操作栏
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 15, bottom: 20),
            child: SizedBox(
              width: 50,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_showActions) ...[
                      SizedBox(
                        width: 56,
                        height: 64,
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.topCenter,
                          children: [
                            UserAvatar(
                              url: widget.video.user.avatar,
                              nickname: widget.video.user.nickname,
                              size: 48,
                              onTap: () {
                                toUserDetailPage(
                                  context: context,
                                  ref: ref,
                                  userId: widget.video.userId,
                                  url: widget.video.user.avatar,
                                  nickname: widget.video.user.nickname,
                                  vip: widget.video.user.vip,
                                );
                              },
                            ),
                            if (!widget.isFollowed)
                              Positioned(
                                bottom: 5,
                                child: GestureDetector(
                                  key: _followBtnKey,
                                  onTap: () async {
                                    _showFollowSplash();
                                    await ref
                                        .read(
                                          userFollowProvider(
                                            widget.video.userId,
                                          ).notifier,
                                        )
                                        .toggleFollow();
                                    widget.onFollowChanged(true);
                                  },
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      Builder(
                        builder: (btnContext) => _buildAction(
                          icon: Icons.favorite,
                          color: widget.isLike
                              ? Colors.red
                              : isTapLike == true
                                  ? Colors.transparent
                                  : Colors.white,
                          onTap: () async {
                            var value = !widget.isLike;
                            if (value) {
                              final renderBox =
                                  btnContext.findRenderObject() as RenderBox;
                              final position = renderBox.localToGlobal(
                                renderBox.size.center(Offset.zero),
                              );
                              _showLikeSplash(position);
                            }
                            await widget.onLikeChanged(value);
                            if (value) {
                              setState(() {
                                _likeCount++;
                              });
                            } else {
                              setState(() {
                                _likeCount--;
                              });
                            }
                          },
                          showText: true,
                          count: _likeCount,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildAction(
                        icon: Icons.comment,
                        color: Colors.white,
                        onTap: () {
                          widget.showModal();
                        },
                        showText: true,
                        count: _commentCount,
                      ),
                      const SizedBox(height: 15),
                      _buildAction(
                        icon: widget.isFavorite
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: widget.isFavorite ? Colors.yellow : Colors.white,
                        onTap: () async {
                          var value = !widget.isFavorite;
                          await widget.onFavoriteChanged(value);
                          if (value) {
                            setState(() {
                              _favoriteCount++;
                            });
                          } else {
                            setState(() {
                              _favoriteCount--;
                            });
                          }
                        },
                        showText: true,
                        count: _favoriteCount,
                      ),
                      const SizedBox(height: 15),
                      if (!kIsWeb)
                        StreamBuilder<Download?>(
                          stream: ref
                              .watch(offlineRepoProvider)
                              .db
                              .watchById(widget.video.id),
                          builder: (context, snapshot) {
                            final existing = snapshot.data;
                            final localPath = existing?.localPath;
                            final fileExists = localPath != null
                                ? File(localPath).existsSync()
                                : false;

                            if (existing == null) {
                              return DownloadButton(
                                videoInfo: widget.video,
                                filename: "video_${widget.video.id}.mp4",
                              );
                            }

                            switch (existing.status) {
                              case "completed":
                                if (fileExists) {
                                  return const Icon(
                                    Icons.download_done,
                                    color: Colors.white,
                                    size: 28.0,
                                  );
                                } else {
                                  return DownloadButton(
                                    videoInfo: widget.video,
                                    filename: "video_${widget.video.id}.mp4",
                                  );
                                }

                              case "paused":
                                return IconButton(
                                  icon: const Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                  ),
                                  onPressed: () async {
                                    final repo = ref.read(offlineRepoProvider);
                                    final i18nNotifier = ref.read(
                                      i18nNotifierProvider.notifier,
                                    );
                                    await repo.resumeDownload(
                                      id: widget.video.id,
                                      translate: i18nNotifier.translate,
                                    );
                                  },
                                );

                              case "failed":
                                return IconButton(
                                  icon: const Icon(
                                    Icons.refresh,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    final repo = ref.read(offlineRepoProvider);
                                    final i18nNotifier = ref.read(
                                      i18nNotifierProvider.notifier,
                                    );
                                    await repo.downloadResource(
                                      id: widget.video.id,
                                      filename: "video_${widget.video.id}.mp4",
                                      translate: i18nNotifier.translate,
                                    );
                                  },
                                );

                              case "cancelled":
                                return DownloadButton(
                                  videoInfo: widget.video,
                                  filename: "video_${widget.video.id}.mp4",
                                );

                              default:
                                return DownloadButton(
                                  videoInfo: widget.video,
                                  filename: "video_${widget.video.id}.mp4",
                                );
                            }
                          },
                        ),
                    ],
                    GestureDetector(
                      onTap: () {
                        widget.onHidden(!_showActions);
                        setState(() {
                          _showActions = !_showActions;
                        });
                      },
                      child: Icon(
                        _showActions ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: isPaid
              ? Padding(
                  padding: const EdgeInsets.only(right: 10, bottom: 15),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          hasWatchTime
                              ? Icons.timer_outlined
                              : Icons.lock_outline,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          hasWatchTime
                              ? _formatSeconds(watchTimeState.remainingSeconds)
                              : '${_previewCountdown}s',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : (widget.video.isBought && widget.video.price > 0)
                  ? const Padding(
                      padding: EdgeInsets.only(right: 10, bottom: 15),
                      child: PurchasedBadge(),
                    )
                  : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class ExpandableText extends StatefulWidget {
  final String text;
  const ExpandableText(this.text, {super.key});

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText>
    with SingleTickerProviderStateMixin {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => expanded = !expanded),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastLinearToSlowEaseIn,
        child: Text(
          widget.text,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          maxLines: expanded ? null : 2,
          overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
