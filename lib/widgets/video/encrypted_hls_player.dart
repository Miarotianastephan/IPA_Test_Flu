import 'dart:async';
import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/api_provider.dart';
import 'package:live_app/services/hls_proxy_server.dart';
import 'package:live_app/widgets/video/mobile_video_controls_overlay.dart';
import 'package:live_app/widgets/video/mobile_video_interaction_layer.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

class EncryptedHlsPlayer extends ConsumerStatefulWidget {
  final String videoUrl;
  final String encryptionKey;
  final EncryptedHlsPlayerController? controller;

  const EncryptedHlsPlayer({
    super.key,
    required this.videoUrl,
    required this.encryptionKey,
    this.controller,
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
    _initializePlayback();
  }

  Future<void> _initializePlayback() async {
    try {
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
      debugPrint('[EncryptedHlsPlayer] Error initializing playback: $e');
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
        if (useMediaKit) {
          player?.pause();
        } else {
          _videoPlayerController?.pause();
        }
      };
      widget.controller!.play = () {
        if (useMediaKit) {
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
      if (!mounted) return;
      if (!isPlaying && !showControls) {
        setState(() => showControls = true);
      }
    });

    try {
      await player!.open(Media(_proxyUrl!), play: false);
    } catch (e) {
      debugPrint('[EncryptedHlsPlayer] Error initializing MediaKit: $e');
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
        final isPaused = !_videoPlayerController!.value.isPlaying;
        if (isPaused && !showControls) {
          if (!mounted) return;
          setState(() => showControls = true);
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
      debugPrint('[EncryptedHlsPlayer] Error initializing Chewie: $e');
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
    await _initializePlayback();
  }

  void _disposePlayer() {
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
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposePlayer();
    HlsProxyServer.instance.unregisterPlaylist(_sessionId);
    HlsProxyServer.instance.release();
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
                icon: const Icon(Icons.refresh),
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
      body: GestureDetector(
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
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
