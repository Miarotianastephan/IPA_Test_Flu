import 'dart:async';
import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:live_app/widgets/video/mobile_video_controls_overlay.dart';
import 'package:live_app/widgets/video/mobile_video_interaction_layer.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:video_player/video_player.dart';

class MobileVideoPlayer extends StatefulWidget {
  final String? videoUrl;
  final String? localPath;
  final VideoScreenController? controller;
  const MobileVideoPlayer({
    super.key,
    this.videoUrl,
    this.localPath,
    this.controller,
  });

  @override
  State<MobileVideoPlayer> createState() => _MobileVideoPlayerState();
}

class VideoScreenController {
  VoidCallback? pause;
}

class _MobileVideoPlayerState extends State<MobileVideoPlayer>
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
      widget.controller != null
          ? widget.controller!.pause = () {
              if (useMediaKit) {
                player?.pause();
              } else {}
            }
          : null;

      if (useMediaKit) {
        player?.play();
      } else {
        _videoPlayerController?.play();
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
    if (player != null) {
      mediaKitController = null;
      player!.pause();
      player?.dispose();
    }
    player = Player();
    mediaKitController = VideoController(player!);
    player?.stream.playing.listen((isPlaying) {
      if (!mounted) return;
      if (!isPlaying && !showControls) {
        setState(() => showControls = true);
      }
    });
    final source =
        widget.localPath != null && File(widget.localPath!).existsSync()
        ? Media(widget.localPath!)
        : Media(widget.videoUrl!);
    try {
      await player!.open(source, play: false);
      await player!.play();

      setState(() {
        isInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing MediaKit: $e');
    }
  }

  Future<void> _initializeChewie() async {
    _videoPlayerController =
        widget.localPath != null && File(widget.localPath!).existsSync()
        ? VideoPlayerController.file(File(widget.localPath!))
        : VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!));
    try {
      await _videoPlayerController!.initialize();
      _videoListener = () {
        final isPaused = !_videoPlayerController!.value.isPlaying;
        if (isPaused && !showControls) {
          if (!mounted) return;
          setState(() => showControls = true);
        }
      };
      _videoPlayerController?.addListener(_videoListener!);
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        showControls: false,
        autoInitialize: true,
      );
    } catch (e) {
      debugPrint('Error initializing Chewie: $e');
    }
  }

  @override
  void dispose() {
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
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      player?.pause();
      _videoPlayerController?.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: isInitialized
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
          : const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
