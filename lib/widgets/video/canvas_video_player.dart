import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/api_provider.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/provider/my_user_provider.dart';
import 'package:live_app/provider/post_detail_provider.dart';
import 'package:live_app/provider/selected_post_provider.dart';
import 'package:live_app/provider/video_detail_provider.dart';
import 'package:live_app/utils/hls_video_utils.dart';
import 'package:live_app/utils/percent_watch.dart';
import 'package:live_app/widgets/video/mobile_video_player.dart';
import 'package:uuid/uuid.dart';
import 'package:web/web.dart' as web;

class CanvasVideoPlayer extends ConsumerStatefulWidget {
  final String videoUrl;
  final String encryptionKey;
  final String videoId;
  final VideoScreenController? controller;
  final ValueNotifier<bool>? playingNotifier;

  const CanvasVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.encryptionKey,
    required this.videoId,
    this.controller,
    this.playingNotifier,
  });

  @override
  ConsumerState<CanvasVideoPlayer> createState() => _CanvasVideoPlayerState();
}

class _CanvasVideoPlayerState extends ConsumerState<CanvasVideoPlayer> {
  final String _viewId = 'canvas-player-${const Uuid().v4()}';
  bool _isLoading = true;
  String? _error;
  HlsJS? _hls;
  web.HTMLVideoElement? _videoElement;
  web.HTMLCanvasElement? _canvasElement;
  String? _blobUrl;
  JSFunction? _stopRenderLoopFn;

  bool _isPlaying = false;
  bool _showControls = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _volume = 1.0;
  Timer? _hideControlsTimer;
  Timer? _positionTimer;
  Timer? _stalledTimer;
  bool _sentPercent = false;
  final double _percentWatch = PercentWatch.percent;

  final _progressCtrl = StreamController<Duration>.broadcast();
  final _completedCtrl = StreamController<void>.broadcast();

  @override
  void initState() {
    super.initState();
    _showControls = true;
    _registerViewFactory();
    _initializePlayback();
  }

  void _registerViewFactory() {
    final iosDevice = isIOS();
    ui_web.platformViewRegistry.registerViewFactory(_viewId, (int viewId) {
      final container = web.document.createElement('div') as web.HTMLDivElement
        ..id = 'canvas-container-$_viewId'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.backgroundColor = 'black'
        ..style.position = 'relative'
        ..style.overflow = 'hidden';

      final video = web.document.createElement('video') as web.HTMLVideoElement
        ..id = 'video-$_viewId'
        ..autoplay = true
        ..playsInline = true
        ..controls = false;

      if (iosDevice) {
        video.style.visibility = 'hidden';
        video.style.position = 'absolute';
        video.style.width = '1px';
        video.style.height = '1px';
      } else {
        video.style.display = 'none';
      }

      final canvas =
          web.document.createElement('canvas') as web.HTMLCanvasElement
            ..id = 'canvas-$_viewId'
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.display = 'block'
            ..style.backgroundColor = 'black';

      container.appendChild(video);
      container.appendChild(canvas);

      _videoElement = video;
      _canvasElement = canvas;
      return container;
    });
  }

  void _startRenderLoop() {
    if (_videoElement == null || _canvasElement == null) return;
    _stopRenderLoopFn = startCanvasRenderLoop(_videoElement!, _canvasElement!);
  }

  void _doStopRenderLoop() {
    _stopRenderLoopFn?.callAsFunction();
    _stopRenderLoopFn = null;
  }

  void _setupVideoListeners() {
    if (_videoElement == null) return;

    _videoElement!.onPlay.listen((_) {
      if (mounted) {
        setState(() => _isPlaying = true);
        widget.playingNotifier?.value = true;
      }
    });

    _videoElement!.onPause.listen((_) {
      if (mounted) {
        setState(() => _isPlaying = false);
        widget.playingNotifier?.value = false;
      }
    });

    _videoElement!.onLoadedMetadata.listen((_) {
      if (mounted) {
        setState(() {
          _duration = _durationFromSeconds(_videoElement!.duration);
          _position = _clampPosition(_position);
        });
      }
    });

    _videoElement!.onError.listen((_) {
      final error = _videoElement!.error;
      if (error != null && mounted) {
        setState(() {
          _error = ref
              .read(i18nNotifierProvider.notifier)
              .translate('videoPlaybackError');
        });
      }
    });

    _videoElement!.onStalled.listen((_) {
      if (!isIOS()) return;

      _stalledTimer?.cancel();
      _stalledTimer = Timer(const Duration(seconds: 5), () {
        if (_videoElement != null && !_isPlaying && _blobUrl != null) {
          final savedTime = _videoElement!.currentTime;
          _videoElement!.load();
          _videoElement!.onCanPlay.first.then((_) {
            _videoElement!.currentTime = savedTime;
            _videoElement!.play();
          });
        }
      });
    });

    _videoElement!.onPlaying.listen((_) {
      _stalledTimer?.cancel();
    });

    _videoElement!.onEnded.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
      widget.playingNotifier?.value = false;
      _completedCtrl.add(null);
    });

    _positionTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (_videoElement != null && mounted) {
        final currentPosition = Duration(
          milliseconds: (_videoElement!.currentTime * 1000).toInt(),
        );

        setState(() {
          _position = _clampPosition(currentPosition);
        });

        _progressCtrl.add(_clampPosition(currentPosition));

        if (_duration != Duration.zero && !_sentPercent) {
          final progress = _normalizedProgress(currentPosition);
          if (progress >= _percentWatch) {
            _sentPercent = true;
            _reportWatchProgress();
          }
        }
      }
    });
  }

  Duration _durationFromSeconds(double seconds) {
    if (!seconds.isFinite || seconds.isNaN || seconds <= 0) {
      return Duration.zero;
    }
    return Duration(milliseconds: (seconds * 1000).toInt());
  }

  Duration _clampPosition(Duration position) {
    if (position.isNegative) return Duration.zero;
    if (_duration == Duration.zero) return position;
    if (position > _duration) return _duration;
    return position;
  }

  double _normalizedProgress(Duration position) {
    if (_duration.inMilliseconds <= 0) return 0.0;
    final progress = position.inMilliseconds / _duration.inMilliseconds;
    if (!progress.isFinite || progress.isNaN) return 0.0;
    return progress.clamp(0.0, 1.0);
  }

  void _reportWatchProgress() {
    final post = ref.read(selectedPostProvider);
    if (post != null) {
      ref
          .read(postDetailProvider(post.id).notifier)
          .userPostInterest(
            interactionType: 'video_completion',
            watchDuration: _position.inSeconds,
            videoDuration: _duration.inSeconds,
          );
    } else {
      ref
          .read(userProvider.notifier)
          .userInterest(
            videoId: widget.videoId,
            watchDuration: _position.inSeconds,
            videoDuration: _duration.inSeconds,
          );
    }
  }

  void _bindController() {
    if (widget.controller == null) return;

    widget.controller!.play = () {
      if (_videoElement == null) return;
      _videoElement!.play().toDart.catchError((_) => null);
    };
    widget.controller!.pause = () {
      _videoElement?.pause();
    };
    widget.controller!.resume = widget.controller!.play;
    widget.controller!.onProgress = _progressCtrl.stream;
    widget.controller!.onCompleted = _completedCtrl.stream;
  }

  void _togglePlay() {
    if (_videoElement == null) return;
    if (_isPlaying) {
      _videoElement!.pause();
    } else {
      if (isIOS() && _videoElement!.readyState < 2) {
        _videoElement!.load();
      }

      _videoElement!
          .play()
          .toDart
          .then((_) {
            if (mounted) setState(() => _isPlaying = true);
          })
          .catchError((error) {
            _videoElement!.load();
            Future.delayed(const Duration(milliseconds: 100), () {
              if (_videoElement != null && mounted) {
                _videoElement!.play().toDart.catchError((_) => null);
              }
            });
            return null;
          });
    }
    _resetHideControlsTimer();
  }

  void _seekTo(Duration position) {
    if (_videoElement == null) return;
    final targetPosition = _clampPosition(position);
    final targetSeconds = targetPosition.inMilliseconds / 1000;
    _videoElement!.currentTime = targetSeconds < 0 ? 0.0 : targetSeconds;
    if (mounted) setState(() => _position = targetPosition);
    _resetHideControlsTimer();
  }

  void _seekRelative(int seconds) {
    if (_videoElement == null) return;
    final nextPosition = Duration(
      milliseconds: ((_videoElement!.currentTime + seconds) * 1000).toInt(),
    );
    _seekTo(nextPosition);
  }

  void _setVolume(double volume) {
    if (_videoElement == null) return;
    _videoElement!.volume = volume;
    setState(() => _volume = volume);
    _resetHideControlsTimer();
  }

  void _toggleFullscreen() {
    final isFullscreen = ref.read(fullscreenProvider);
    ref.read(fullscreenProvider.notifier).state = !isFullscreen;
    _resetHideControlsTimer();
  }

  void _showControlsTemporarily() {
    setState(() => _showControls = true);
    _resetHideControlsTimer();
  }

  void _resetHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _isPlaying) setState(() => _showControls = false);
    });
  }

  @override
  void dispose() {
    _doStopRenderLoop();
    if (widget.controller != null) {
      widget.controller!.play = null;
      widget.controller!.pause = null;
      widget.controller!.resume = null;
    }
    _hideControlsTimer?.cancel();
    _positionTimer?.cancel();
    _stalledTimer?.cancel();
    _hls?.destroy();
    _hls = null;
    if (_blobUrl != null) {
      web.URL.revokeObjectURL(_blobUrl!);
    }
    _videoElement = null;
    _canvasElement = null;
    _progressCtrl.close();
    _completedCtrl.close();
    super.dispose();
  }

  Future<void> _initializePlayback() async {
    try {
      final playbackInfo = await ref
          .read(videoServiceProvider)
          .playVideo(videoUrl: widget.videoUrl, key: widget.encryptionKey);

      final rewrittenM3u8 = rewriteM3u8WithAbsoluteUrls(
        playbackInfo.m3u8Content,
        widget.videoUrl,
      );

      if (isIOS() || supportsNativeHls()) {
        final base64Content = base64Encode(utf8.encode(rewrittenM3u8));
        _blobUrl = 'data:application/x-mpegURL;base64,$base64Content';
      } else {
        final blob = web.Blob(
          [rewrittenM3u8.toJS].toJS,
          web.BlobPropertyBag(type: 'application/x-mpegURL'),
        );
        _blobUrl = web.URL.createObjectURL(blob);
      }

      if (mounted) {
        setState(() => _isLoading = false);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _initializeHls();
          _setupVideoListeners();
          _bindController();
          _resetHideControlsTimer();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = ref
              .read(i18nNotifierProvider.notifier)
              .translate('errorLoadingVideo');
          _isLoading = false;
        });
      }
    }
  }

  void _initializeHls() {
    if (_videoElement == null || _blobUrl == null) return;

    try {
      if (HlsJS.isSupported()) {
        _hls = HlsJS();
        _hls!.on('hlsError', ((JSAny event, JSAny data) {}).toJS);
        _hls!.loadSource(_blobUrl!);
        _hls!.attachMedia(_videoElement!);
      } else if (supportsNativeHls()) {
        _videoElement!.src = _blobUrl!;
        _videoElement!.load();
      } else {
        _videoElement!.src = _blobUrl!;
      }

      _startRenderLoop();
    } catch (e) {
      setState(() {
        _error = ref
            .read(i18nNotifierProvider.notifier)
            .translate('failedToInitializePlayer');
      });
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String txt) => i18n.translate(txt);

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.12),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _initializePlayback();
              },
              child: Text(translate('retry')),
            ),
          ],
        ),
      );
    }

    final showFlutterControls = _showControls;

    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _showControlsTemporarily,
          child: IgnorePointer(
            ignoring: true,
            child: HtmlElementView(viewType: _viewId),
          ),
        ),
        if (showFlutterControls)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.0),
                    Colors.black.withValues(alpha: 0.0),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: IconButton(
                      iconSize: 64,
                      icon: Icon(
                        _isPlaying ? Icons.pause_circle : Icons.play_circle,
                        color: Colors.white.withAlpha(150),
                      ),
                      onPressed: _togglePlay,
                    ),
                  ),
                  Positioned(
                    bottom: 5,
                    left: 0,
                    right: 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 4,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 12,
                              ),
                              activeTrackColor: Colors.red,
                              inactiveTrackColor: Colors.grey,
                              thumbColor: Colors.red,
                            ),
                            child: Slider(
                              value: _normalizedProgress(_position),
                              onChanged: (value) {
                                final newPosition = Duration(
                                  milliseconds:
                                      (value * _duration.inMilliseconds)
                                          .toInt(),
                                );
                                _seekTo(newPosition);
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 2.0,
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  _isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                ),
                                onPressed: _togglePlay,
                              ),
                              Text(
                                '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.replay_10,
                                  color: Colors.white,
                                ),
                                onPressed: () => _seekRelative(-10),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.forward_10,
                                  color: Colors.white,
                                ),
                                onPressed: () => _seekRelative(10),
                              ),
                              const Spacer(),
                              PopupMenuButton<double>(
                                color: Colors.transparent,
                                icon: Icon(
                                  _volume == 0
                                      ? Icons.volume_off
                                      : Icons.volume_up,
                                  color: Colors.white,
                                ),
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    enabled: false,
                                    child: StatefulBuilder(
                                      builder: (context, setMenuState) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.remove,
                                                  color: Colors.black,
                                                ),
                                                onPressed: () {
                                                  final newVolume =
                                                      (_volume - 0.1).clamp(
                                                        0.0,
                                                        1.0,
                                                      );
                                                  setMenuState(
                                                    () => _setVolume(newVolume),
                                                  );
                                                },
                                              ),
                                              Text(
                                                '${(_volume * 100).toInt()}%',
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.add,
                                                  color: Colors.black,
                                                ),
                                                onPressed: () {
                                                  final newVolume =
                                                      (_volume + 0.1).clamp(
                                                        0.0,
                                                        1.0,
                                                      );
                                                  setMenuState(
                                                    () => _setVolume(newVolume),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: Icon(
                                  ref.watch(fullscreenProvider)
                                      ? Icons.fullscreen_exit
                                      : Icons.fullscreen,
                                  color: Colors.white,
                                ),
                                onPressed: _toggleFullscreen,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
