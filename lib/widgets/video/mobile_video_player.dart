import 'dart:async';
import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/widgets/video/mobile_video_controls_overlay.dart';
import 'package:live_app/widgets/video/mobile_video_interaction_layer.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class MobileVideoPlayer extends ConsumerStatefulWidget {
  final String? videoUrl;
  final String? localPath;
  final VideoScreenController? controller;
  final bool autoPlay;
  const MobileVideoPlayer({
    super.key,
    this.videoUrl,
    this.localPath,
    this.controller,
    this.autoPlay = true,
  });
  @override
  ConsumerState<MobileVideoPlayer> createState() => _MobileVideoPlayerState();
}

class VideoScreenController {
  VoidCallback? play;
  VoidCallback? pause;
  VoidCallback? resume;
  Stream<Duration>? onProgress;
  Stream<void>? onCompleted;
}

class _MobileVideoPlayerState extends ConsumerState<MobileVideoPlayer>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  bool useMediaKit = false;
  bool isInitialized = false;
  Player? player;
  VideoController? mediaKitController;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool showControls = true;
  Timer? _hideTimer;
  VoidCallback? _videoListener;
  final _progressCtrl = StreamController<Duration>.broadcast();
  final _completedCtrl = StreamController<void>.broadcast();
  bool _isPlayerDisposed = false;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      useMediaKit = await _isHarmonyOS();
      if (useMediaKit) {
        await _initializeMediaKit();
      } else {
        await _initializeChewie();
      }
      if (widget.controller != null) {
        widget.controller!.onProgress = _progressCtrl.stream;
        widget.controller!.onCompleted = _completedCtrl.stream;
        widget.controller!.play = () {
          if (useMediaKit && !_isPlayerDisposed) {
            player?.play();
          } else {
            _videoPlayerController?.play();
          }
        };
        widget.controller!.pause = () {
          if (useMediaKit && !_isPlayerDisposed) {
            player?.pause();
          } else {
            _videoPlayerController?.pause();
          }
        };
        widget.controller!.resume = () {
          if (useMediaKit && !_isPlayerDisposed) {
            player?.play();
          } else {
            _videoPlayerController?.play();
          }
        };
      }

      if (widget.autoPlay) {
        if (useMediaKit && !_isPlayerDisposed) {
          player?.play();
        } else {
          _videoPlayerController?.play();
        }
      }

      setState(() {
        isInitialized = true;
      });
      _showControls();
    });
  }

  void _showControls() {
    setState(() {
      showControls = true;
    });
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 10), () {
      setState(() {
        showControls = false;
      });
    });
  }

  Future<bool> _isHarmonyOS() async {
    if (!Platform.isAndroid) return false;
    final info = await DeviceInfoPlugin().androidInfo;
    return info.manufacturer.toLowerCase() == 'huawei';
  }

  Future<void> _initializeMediaKit() async {
    WidgetsBinding.instance.removeObserver(this);
    if (player != null && !_isPlayerDisposed) {
      mediaKitController = null;
      player!.pause();
      player?.dispose();
    }
    player = Player();
    mediaKitController = VideoController(player!);
    player?.stream.playing.listen((isPlaying) {
      if (!mounted || _isPlayerDisposed) return;

      if (!isPlaying && !showControls) {
        setState(() => showControls = true);
      }
    });
    player!.stream.position.listen((pos) {
      if (!_isPlayerDisposed) {
        _progressCtrl.add(pos);
      }
    });
    player!.stream.completed.listen((completed) {
      if (!_isPlayerDisposed && completed) {
        _completedCtrl.add(null);
      }
    });
    final source =
        widget.localPath != null && File(widget.localPath!).existsSync()
        ? Media(widget.localPath!)
        : Media(widget.videoUrl!);
    try {
      if (_isPlayerDisposed) return;
      await player!.open(source, play: false);
      if (_isPlayerDisposed) return;
      await player!.play();

      setState(() {
        isInitialized = true;
      });
    } catch (e) {}
  }

  Future<void> _initializeChewie() async {
    _videoPlayerController =
        widget.localPath != null && File(widget.localPath!).existsSync()
        ? VideoPlayerController.file(File(widget.localPath!))
        : VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!));
    try {
      await _videoPlayerController!.initialize();
      _videoListener = () {
        final v = _videoPlayerController!.value;
        _progressCtrl.add(v.position);
        if (v.duration > Duration.zero &&
            v.position >= v.duration - const Duration(milliseconds: 200)) {
          _completedCtrl.add(null);
        }
        final isPaused = !v.isPlaying;
        if (isPaused && !showControls) {
          if (!mounted) return;
          setState(() => showControls = true);
        }
      };
      _videoPlayerController?.addListener(_videoListener!);
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: widget.autoPlay,
        looping: false,
        showControls: false,
        autoInitialize: true,
      );
    } catch (e) {}
  }

  @override
  void dispose() {
    _isPlayerDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _hideTimer?.cancel();
    _hideTimer = null;
    player?.pause();
    player?.dispose();
    player = null;
    mediaKitController = null;
    if (_videoListener != null) {
      _videoPlayerController?.removeListener(_videoListener!);
      _videoListener = null;
    }
    _videoPlayerController?.dispose();
    _videoPlayerController = null;
    _chewieController?.dispose();
    _chewieController = null;
    _progressCtrl.close();
    _completedCtrl.close();
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
    if (!mounted || _isPlayerDisposed) return;
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: VisibilityDetector(
        key: Key('mobile-video-player-${widget.videoUrl ?? widget.localPath}'),
        onVisibilityChanged: _handleVisibilityChanged,
        child: isInitialized
            ? GestureDetector(
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
                ),
              )
            : const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
      ),
    );
  }
}
