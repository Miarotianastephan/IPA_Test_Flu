import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:live_app/models/ad.dart';
import 'package:live_app/provider/api_provider.dart';
import 'package:live_app/provider/web_video_mute_provider.dart';
import 'package:live_app/utils/ad_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../api/services/video_service.dart';
import '../encrypted_image.dart';
import '../video/bw_progress.dart';
import '../video/short_video_item_stub.dart'
    if (dart.library.io) '../video/short_video_item_mobile_impl.dart'
    if (dart.library.html) '../video/short_video_item_web_impl.dart'
    as platform_impl;

class AdShortVideo extends ConsumerStatefulWidget {
  final Ad ad;
  final VoidCallback? onInitialized;

  const AdShortVideo({super.key, required this.ad, this.onInitialized});

  @override
  ConsumerState<AdShortVideo> createState() => _AdShortVideoWidgetState();
}

class _AdShortVideoWidgetState extends ConsumerState<AdShortVideo> {
  platform_impl.PlatformVideoPlayer? _platformPlayer;
  bool _showVideo = false;
  bool _hasCalledOnInitialized = false;
  double _lastVisibleFraction = 0;
  late VideoService videoService;

  @override
  void initState() {
    super.initState();
    videoService = ref.read(videoServiceProvider);
    _initializeVideo();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupMuteListener();
    });
  }

  @override
  void didUpdateWidget(AdShortVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ad.videoUrl != oldWidget.ad.videoUrl) {
      _showVideo = false;
      _disposePlayer();
      _initializeVideo();
    }
  }

  void _setupMuteListener() {
    ref.listenManual(webVideoMuteProvider, (previous, next) {
      if (previous?.isMuted != next.isMuted) {
        _platformPlayer?.setMuted(next.isMuted);
      }
    });
  }

  Future<void> _initializeVideo() async {
    final ad = widget.ad;
    final videoUrl = ad.videoUrl;

    if (videoUrl == null || videoUrl.isEmpty) {
      return;
    }

    final encryptionKey = ad.encryptionKey;
    // final encryptionKey = "xokey";

    _platformPlayer = platform_impl.createPlatformVideoPlayer(
      onLoaded: () {
        if (!mounted || _showVideo) return;
        setState(() {
          _showVideo = true;
        });
      },
      onPlay: () {},
      onPause: () {},
      onMute: () {
        ref.read(webVideoMuteProvider.notifier).setMuted(true);
      },
    );

    try {
      final playbackInfo = await videoService.playVideo(
        videoUrl: videoUrl,
        key: encryptionKey,
      );

      await _platformPlayer!.initialize(
        playbackInfo.m3u8Content,
        videoUrl,
        encryptionKey,
        videoId: ad.id.toString(),
      );
    } catch (_) {}

    if (mounted) {
      _syncMuteState();
    }
  }

  void _syncMuteState() {
    if (_platformPlayer == null) return;
    final muteState = ref.read(webVideoMuteProvider);
    _platformPlayer!.setMuted(muteState.isMuted);
  }

  void _disposePlayer() {
    _platformPlayer?.dispose();
    _platformPlayer = null;
  }

  @override
  void dispose() {
    _disposePlayer();
    super.dispose();
  }

  void _play() {
    if (!mounted) return;
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

    final duration = widget.ad.videoDuration ?? 0;
    if (duration == 0) return const SizedBox.shrink();

    return ValueListenableBuilder<Duration>(
      valueListenable: _platformPlayer!.positionListenable,
      builder: (_, position, __) {
        final totalDuration = Duration(seconds: duration);
        final progress = totalDuration.inMilliseconds == 0
            ? 0.0
            : position.inMilliseconds / totalDuration.inMilliseconds;

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
                _seekTo(totalDuration * x);
              },
              onHorizontalDragUpdate: (details) {
                final box = context.findRenderObject() as RenderBox;
                final dx = box.globalToLocal(details.globalPosition).dx;
                final x = (dx / box.size.width).clamp(0.0, 1.0);
                _seekTo(totalDuration * x);
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
                        _seekTo(totalDuration * value);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _autoPlayIfVisible() {
    if (!mounted ||
        _platformPlayer == null ||
        _platformPlayer!.isPlayingListenable.value) {
      return;
    }
    if (!kIsWeb && _lastVisibleFraction > 0.65) {
      _play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ad = widget.ad;
    final hasVideo = ad.videoUrl != null && ad.videoUrl!.isNotEmpty;
    final coverUrl = ad.videoCoverUrl ?? ad.imageLargeUrl ?? ad.imageMediumUrl;

    return Stack(
      children: [
        // Cover image
        if (coverUrl != null)
          Positioned.fill(
            child: EncryptedImage(
              url: coverUrl,
              fit: BoxFit.cover,
              errorWidget: const Icon(Icons.broken_image, size: 40),
            ),
          ),

        // Video player
        if (hasVideo && _platformPlayer != null)
          Positioned.fill(
            child: ValueListenableBuilder<bool>(
              valueListenable: _platformPlayer!.isInitializedListenable,
              builder: (_, ready, __) {
                if (!ready) return const SizedBox.shrink();

                if (!_hasCalledOnInitialized) {
                  _hasCalledOnInitialized = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    widget.onInitialized?.call();
                    _autoPlayIfVisible();
                  });
                }

                return VisibilityDetector(
                  key: Key('ad_visibility_${ad.id}_$hashCode'),
                  onVisibilityChanged: (info) {
                    _lastVisibleFraction = info.visibleFraction;

                    final player = _platformPlayer;
                    if (!mounted || player == null) return;

                    final isPlaying = player.isPlayingListenable.value;

                    if (info.visibleFraction == 0) {
                      _pause();
                    } else if (info.visibleFraction > 0.65) {
                      if (!isPlaying) {
                        _play();
                      }
                    }
                  },
                  child: AnimatedOpacity(
                    opacity: _showVideo ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: _platformPlayer!.buildVideoWidget(fit: BoxFit.cover),
                  ),
                );
              },
            ),
          ),

        // Buffering indicator
        if (hasVideo && _platformPlayer != null)
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: ValueListenableBuilder<bool>(
                  valueListenable: _platformPlayer!.isBufferingListenable,
                  builder: (_, isBuffering, __) {
                    return isBuffering
                        ? const BWProgress()
                        : const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ),

        // Tap to play/pause
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (_platformPlayer == null) return;
              final isPlaying = _platformPlayer!.isPlayingListenable.value;
              if (isPlaying) {
                _pause();
              } else {
                _play();
              }
            },
            child: hasVideo && _platformPlayer != null
                ? Center(
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _platformPlayer!.isPlayingListenable,
                      builder: (_, isPlaying, __) {
                        return AnimatedOpacity(
                          opacity: isPlaying ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white.withValues(alpha: 0.6),
                            size: 128,
                          ),
                        );
                      },
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),

        // Progress slider
        if (hasVideo)
          Positioned(
            left: 0,
            right: 0,
            bottom: 5.0,
            child: _buildProgressSlider(context),
          ),

        Positioned(
          left: 6,
          right: 0,
          bottom: 20,
          child: AdBanner(
            ad: ad,
            onTap: () {
              onAdRedirection(ad, ref);
            },
          ),
        ),
      ],
    );
  }
}

class AdBanner extends StatelessWidget {
  final Ad ad;
  final VoidCallback? onTap;

  const AdBanner({super.key, required this.ad, this.onTap});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: 0.75,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.75),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                // App icon
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: ad.imageMediumUrl != null
                        ? EncryptedImage(
                            url: ad.imageMediumUrl!,
                            fit: BoxFit.cover,
                            errorWidget: Container(
                              color: Colors.white,
                              child: const Icon(Icons.apps, color: Colors.grey),
                            ),
                          )
                        : Container(
                            color: Colors.white,
                            child: const Icon(Icons.apps, color: Colors.grey),
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        ad.adTitle!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ad.adDescription!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // CTA button
          if (ad.ctaText != null)
            GestureDetector(
              onTap: onTap,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFFD81B60),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      ad.ctaText!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
