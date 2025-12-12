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
  final String videoUrl;
  final VideoScreenController? controller;
  const MobileVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.controller,
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
      if (!isPlaying && !showControls) {
        setState(() => showControls = true);
      }
    });
    try {
      await player!.open(Media(widget.videoUrl), play: false);
      await player!.play();

      setState(() {
        isInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing MediaKit: $e');
    }
  }

  Future<void> _initializeChewie() async {
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );

    try {
      await _videoPlayerController!.initialize();
      _videoPlayerController?.addListener(() {
        final isPaused = !_videoPlayerController!.value.isPlaying;
        if (isPaused && !showControls) {
          setState(() => showControls = true);
        }
      });
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
    player?.pause();
    player?.dispose();
    player = null;
    mediaKitController = null;
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
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
