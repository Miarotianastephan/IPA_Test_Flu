import 'dart:async';
import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/api_provider.dart';
import 'package:live_app/provider/my_user_provider.dart';
import 'package:live_app/provider/post_detail_provider.dart';
import 'package:live_app/provider/selected_post_provider.dart';
import 'package:live_app/services/hls_proxy_server.dart';
import 'package:live_app/utils/percent_watch.dart';
import 'package:live_app/widgets/video/mobile_video_controls_overlay.dart';
import 'package:live_app/widgets/video/mobile_video_interaction_layer.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class EncryptedHlsPlayer extends ConsumerStatefulWidget {
  final String videoUrl;
  final String encryptionKey;
  final EncryptedHlsPlayerController? controller;
  final ValueNotifier<bool>? playingNotifier;
  final String? categoryId;
  final String videoId;
  final VoidCallback? onVideoEnded;
  final String? preloadedProxyUrl;
  final String? preloadedSessionId;
  final bool showPlayerControls;

  const EncryptedHlsPlayer({
    super.key,
    required this.videoUrl,
    required this.encryptionKey,
    this.controller,
    this.playingNotifier,
    this.categoryId,
    required this.videoId,
    this.onVideoEnded,
    this.preloadedProxyUrl,
    this.preloadedSessionId,
    this.showPlayerControls = true,
  });

  @override
  ConsumerState<EncryptedHlsPlayer> createState() => _EncryptedHlsPlayerState();
}

class EncryptedHlsPlayerController {
  VoidCallback? pause;
  VoidCallback? play;
  VoidCallback? dispose;
}

class _EncryptedHlsPlayerState extends ConsumerState<EncryptedHlsPlayer>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  final String _sessionId = const Uuid().v4();
  String? _proxyUrl;
  bool _isLoading = true;
  String? _error;

  bool useMediaKit = false;
  bool isPlayerInitialized = false;
  bool _isDisposing = false;
  bool _isPlayerDisposed = false;
  Player? player;
  VideoController? mediaKitController;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool showControls = true;
  Timer? _hideTimer;
  VoidCallback? _videoListener;

  Duration? _totalDuration;
  bool _sentPercent = false;
  double percentWatch = PercentWatch.percent;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializePlayback();
  }

  Future<void> _initializePlayback() async {
    try {
      if (widget.preloadedProxyUrl != null) {
        _proxyUrl = widget.preloadedProxyUrl;

        setState(() {
          _isLoading = false;
        });

        await _initializePlayer();
        return;
      }

      HlsProxyServer.instance.acquire();
      await HlsProxyServer.instance.start();

      final playbackInfo = await ref
          .read(videoServiceProvider)
          .playVideo(videoUrl: widget.videoUrl, key: widget.encryptionKey);

      _proxyUrl = HlsProxyServer.instance.registerPlaylist(
        _sessionId,
        playbackInfo.m3u8Content,
        baseUrl: widget.videoUrl,
      );

      setState(() {
        _isLoading = false;
      });

      await _initializePlayer();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _initializePlayer() async {
    if (_proxyUrl == null) return;

    useMediaKit = await _isHarmonyOS();

    if (useMediaKit) {
      await _initializeMediaKit();
    } else {
      await _initializeChewie();
    }

    _setupController();
    _showControls();

    if (useMediaKit) {
      player?.play();
    } else {
      _videoPlayerController?.play();
    }

    setState(() {
      isPlayerInitialized = true;
    });
  }

  void _setupController() {
    if (widget.controller != null) {
      widget.controller!.pause = () {
        if (useMediaKit && !_isPlayerDisposed) {
          player?.pause();
        } else {
          _videoPlayerController?.pause();
        }
      };
      widget.controller!.play = () {
        if (useMediaKit && !_isPlayerDisposed) {
          player?.play();
        } else {
          _videoPlayerController?.play();
        }
      };
    }
  }

  void _showControls() {
    setState(() {
      showControls = true;
    });
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          showControls = false;
        });
      }
    });
  }

  Future<bool> _isHarmonyOS() async {
    if (!Platform.isAndroid) return false;
    final info = await DeviceInfoPlugin().androidInfo;
    return info.manufacturer.toLowerCase() == 'huawei';
  }

  Future<void> _initializeMediaKit() async {
    if (player != null) {
      mediaKitController = null;
      player!.pause();
      player?.dispose();
    }
    player = Player();
    mediaKitController = VideoController(player!);

    player?.stream.playing.listen((isPlaying) {
      if (!mounted || _isDisposing || _isPlayerDisposed) return;

      widget.playingNotifier?.value = isPlaying;

      if (!isPlaying && !showControls) {
        setState(() => showControls = true);
      }
    });

    player!.stream.duration.listen((duration) {
      if (!mounted || _isDisposing) return;
      _totalDuration = duration;
    });

    player!.stream.position.listen((position) {
      if (!mounted || _isDisposing) return;

      if (position.inSeconds >= _totalDuration!.inSeconds * percentWatch &&
          !_sentPercent) {
        _sentPercent = true;

        final post = ref.watch(selectedPostProvider);
        if (post != null) {
          ref
              .read(postDetailProvider(post.id).notifier)
              .userPostInterest(
                interactionType: 'video_completion',
                watchDuration: position.inSeconds,
                videoDuration: _totalDuration!.inSeconds,
              );
        } else {
          ref
              .read(userProvider.notifier)
              .userInterest(
                videoId: widget.videoId,
                watchDuration: position.inSeconds,
                videoDuration: _totalDuration!.inSeconds,
              );
        }
      }
    });

    player!.stream.completed.listen((completed) {
      if (!mounted || _isDisposing) return;
      if (completed) {
        widget.onVideoEnded?.call();
      }
    });

    player!.stream.error.listen((error) {
      if (!mounted || _isDisposing) return;
      debugPrint('[EncryptedHlsPlayer] MediaKit error: $error');
      setState(() {
        _error = error;
      });
    });

    try {
      await player!.open(Media(_proxyUrl!), play: false);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _initializeChewie() async {
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(_proxyUrl!),
    );

    try {
      await _videoPlayerController!.initialize();

      _videoListener = () {
        if (!mounted || _isDisposing || _videoPlayerController == null) return;

        final value = _videoPlayerController!.value;

        if (value.hasError) {
          debugPrint(
            '[EncryptedHlsPlayer] Playback error: ${value.errorDescription}',
          );
          setState(() {
            _error = value.errorDescription ?? 'Playback error occurred';
          });
          return;
        }

        final isPlaying = value.isPlaying;
        final position = value.position;
        final duration = value.duration;

        widget.playingNotifier?.value = isPlaying;

        if (duration != Duration.zero && _totalDuration == null) {
          _totalDuration = duration;
        }

        if (_totalDuration != null && !_sentPercent) {
          final progress =
              position.inMilliseconds / _totalDuration!.inMilliseconds;

          if (progress >= percentWatch) {
            _sentPercent = true;

            final post = ref.watch(selectedPostProvider);

            if (post != null) {
              ref
                  .read(postDetailProvider(post.id).notifier)
                  .userPostInterest(
                    interactionType: 'video_completion',
                    watchDuration: position.inSeconds,
                    videoDuration: _totalDuration!.inSeconds,
                  );
            } else {
              ref
                  .read(userProvider.notifier)
                  .userInterest(
                    videoId: widget.videoId,
                    watchDuration: position.inSeconds,
                    videoDuration: _totalDuration!.inSeconds,
                  );
            }
          }
        }

        if (!isPlaying && !showControls) {
          setState(() => showControls = true);
        }

        if (duration != Duration.zero &&
            position >= duration &&
            !value.isPlaying) {
          widget.onVideoEnded?.call();
        }
      };

      _videoPlayerController?.addListener(_videoListener!);

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: false,
        looping: false,
        showControls: false,
        autoInitialize: true,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _retry() async {
    setState(() {
      _isLoading = true;
      _error = null;
      isPlayerInitialized = false;
    });

    _disposePlayer();
    _isDisposing = false;
    await _initializePlayback();
  }

  void _disposePlayer() {
    if (_isDisposing) return;
    _isDisposing = true;
    _isPlayerDisposed = true;

    _hideTimer?.cancel();
    _hideTimer = null;

    if (!_isPlayerDisposed) {
      player?.pause();
      player?.dispose();
    }
    player = null;
    mediaKitController = null;

    if (_videoListener != null && _videoPlayerController != null) {
      _videoPlayerController?.removeListener(_videoListener!);
      _videoListener = null;
    }

    if (_chewieController != null) {
      try {
        _chewieController!.dispose();
      } catch (e) {
        debugPrint('[EncryptedHlsPlayer] Error disposing ChewieController: $e');
      }
      _chewieController = null;
    }

    if (_videoPlayerController != null) {
      try {
        _videoPlayerController!.dispose();
      } catch (e) {
        debugPrint(
          '[EncryptedHlsPlayer] Error disposing VideoPlayerController: $e',
        );
      }
      _videoPlayerController = null;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposePlayer();
    if (widget.preloadedProxyUrl == null) {
      HlsProxyServer.instance.unregisterPlaylist(_sessionId);
    }
    HlsProxyServer.instance.release();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      if (!_isPlayerDisposed) {
        player?.pause();
      }
      _videoPlayerController?.pause();
    }
  }

  @override
  bool get wantKeepAlive => true;

  void _handleVisibilityChanged(VisibilityInfo info) {
    if (info.visibleFraction < 0.6) {
      if (useMediaKit && !_isPlayerDisposed) {
        player?.pause();
      } else {
        _videoPlayerController?.pause();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 48),
              const SizedBox(height: 16),
              Text(
                'Playback Error',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _error!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _retry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (!isPlayerInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: VisibilityDetector(
        key: Key('encrypted-hls-player-${widget.videoUrl}'),
        onVisibilityChanged: _handleVisibilityChanged,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (showControls) {
              setState(() => showControls = false);
              _hideTimer?.cancel();
            } else {
              _showControls();
            }
          },
          child: Stack(
            children: [
              useMediaKit
                  ? Video(controller: mediaKitController!, controls: null)
                  : _chewieController != null
                  ? Chewie(controller: _chewieController!)
                  : const SizedBox.shrink(),
              if (widget.showPlayerControls) ...[
                MobileVideoInteractionLayer(
                  player: player,
                  useMediaKit: useMediaKit,
                  chewieController: _chewieController,
                ),
                AnimatedOpacity(
                  opacity: showControls ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: MobileVideoControlsOverlay(
                    player: player,
                    useMediaKit: useMediaKit,
                    chewieController: _chewieController,
                    videoController: _videoPlayerController,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
