import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:live_app/services/hls_proxy_server.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

import '../../api/services/video_service.dart';
import 'short_video_item_stub.dart';

export 'short_video_item_stub.dart' show PlatformVideoPlayer;

class MobilePlatformVideoPlayer implements PlatformVideoPlayer {
  final VideoService videoService;
  final VoidCallback onStateChanged;

  bool _useMediaKit = false;
  bool _platformChecked = false;

  VideoPlayerController? _videoController;
  Player? _mediaKitPlayer;
  VideoController? _mediaKitController;
  StreamSubscription<bool>? _bufferingSubscription;

  final String _sessionId = const Uuid().v4();
  String? _proxyUrl;

  bool _isInitialized = false;
  bool _isBuffering = true;

  MobilePlatformVideoPlayer({
    required this.videoService,
    required this.onStateChanged,
  });

  @override
  bool get isInitialized => _isInitialized;

  @override
  bool get isPlaying {
    if (_useMediaKit) {
      return _mediaKitPlayer?.state.playing ?? false;
    }
    return _videoController?.value.isPlaying ?? false;
  }

  @override
  bool get isBuffering => _isBuffering;

  @override
  Duration get position {
    if (_useMediaKit) {
      return _mediaKitPlayer?.state.position ?? Duration.zero;
    }
    return _videoController?.value.position ?? Duration.zero;
  }

  @override
  Duration get duration {
    if (_useMediaKit) {
      return _mediaKitPlayer?.state.duration ?? Duration.zero;
    }
    return _videoController?.value.duration ?? Duration.zero;
  }

  Future<bool> _isHuaweiDevice() async {
    if (!Platform.isAndroid) return false;
    final info = await DeviceInfoPlugin().androidInfo;
    return info.manufacturer.toLowerCase() == 'huawei';
  }

  @override
  Future<void> initialize(String videoUrl, String encryptionKey) async {
    try {
      if (!_platformChecked) {
        _useMediaKit = await _isHuaweiDevice();
        _platformChecked = true;
      }

      HlsProxyServer.instance.acquire();
      await HlsProxyServer.instance.start();

      final playbackInfo = await videoService.playVideo(
        videoUrl: videoUrl,
        key: encryptionKey,
      );

      _proxyUrl = HlsProxyServer.instance.registerPlaylist(
        _sessionId,
        playbackInfo.m3u8Content,
        baseUrl: videoUrl,
      );

      if (_useMediaKit) {
        await _initializeMediaKit();
      } else {
        await _initializeVideoPlayer();
      }
    } catch (e) {
      debugPrint('Error initializing video with proxy: $e');
    }
  }

  Future<void> _initializeMediaKit() async {
    if (_proxyUrl == null) return;

    _mediaKitPlayer = Player();
    _mediaKitController = VideoController(_mediaKitPlayer!);

    _bufferingSubscription = _mediaKitPlayer!.stream.buffering.listen((
      isBuffering,
    ) {
      _isBuffering = isBuffering;
      onStateChanged();
    });

    try {
      await _mediaKitPlayer!.open(Media(_proxyUrl!), play: false);
      _isInitialized = true;
      _isBuffering = false;
      onStateChanged();
    } catch (e) {
      debugPrint('Error initializing MediaKit: $e');
    }
  }

  Future<void> _initializeVideoPlayer() async {
    if (_proxyUrl == null) return;

    _videoController = VideoPlayerController.networkUrl(Uri.parse(_proxyUrl!));

    try {
      await _videoController!.initialize();
      _isInitialized = true;

      _videoController!.addListener(() {
        final value = _videoController!.value;
        if (_isBuffering != value.isBuffering) {
          _isBuffering = value.isBuffering;
          onStateChanged();
        }
      });

      _isBuffering = false;
      onStateChanged();
    } catch (e) {
      debugPrint('Error initializing VideoPlayer: $e');
    }
  }

  @override
  void play() {
    if (_useMediaKit) {
      _mediaKitPlayer?.play();
    } else {
      _videoController?.play();
    }
  }

  @override
  void pause() {
    if (_useMediaKit) {
      _mediaKitPlayer?.pause();
    } else {
      _videoController?.pause();
    }
  }

  @override
  void seekTo(Duration position) {
    if (_useMediaKit) {
      _mediaKitPlayer?.seek(position);
    } else {
      _videoController?.seekTo(position);
    }
  }

  @override
  void dispose() {
    if (_proxyUrl != null) {
      HlsProxyServer.instance.unregisterPlaylist(_sessionId);
      _proxyUrl = null;
    }

    if (_useMediaKit) {
      _bufferingSubscription?.cancel();
      _mediaKitPlayer?.dispose();
      _mediaKitPlayer = null;
      _mediaKitController = null;
    } else {
      _videoController?.dispose();
      _videoController = null;
    }

    HlsProxyServer.instance.release();
  }

  @override
  Widget buildVideoWidget({required BoxFit fit}) {
    if (_useMediaKit && _mediaKitController != null) {
      return Video(
        controller: _mediaKitController!,
        controls: NoVideoControls,
        fit: fit,
      );
    } else if (_videoController != null) {
      return SizedBox.expand(
        child: FittedBox(
          fit: fit,
          child: SizedBox(
            width: _videoController!.value.size.width,
            height: _videoController!.value.size.height,
            child: VideoPlayer(_videoController!),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Stream<Duration>? get positionStream {
    if (_useMediaKit) {
      return _mediaKitPlayer?.stream.position;
    }
    return null;
  }

  VideoPlayerController? get videoPlayerController => _videoController;

  bool get usesMediaKit => _useMediaKit;
}

PlatformVideoPlayer createPlatformVideoPlayer({
  required VideoService videoService,
  required VoidCallback onStateChanged,
}) {
  return MobilePlatformVideoPlayer(
    videoService: videoService,
    onStateChanged: onStateChanged,
  );
}
