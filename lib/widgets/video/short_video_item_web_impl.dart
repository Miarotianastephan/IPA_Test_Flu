import 'dart:async';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:web/web.dart' as web;

import '../../api/services/video_service.dart';
import 'short_video_item_stub.dart';

export 'short_video_item_stub.dart' show PlatformVideoPlayer;

@JS('Hls')
extension type HlsJS._(JSObject _) implements JSObject {
  external factory HlsJS();
  external static bool isSupported();
  external void loadSource(String src);
  external void attachMedia(web.HTMLVideoElement video);
  external void destroy();
  external void on(String event, JSFunction callback);
}

@JS('JSON.stringify')
external String _jsonStringify(JSAny? obj);

class WebPlatformVideoPlayer implements PlatformVideoPlayer {
  final VideoService videoService;
  final VoidCallback onStateChanged;

  final String _viewId = 'hls-short-video-${const Uuid().v4()}';
  HlsJS? _hls;
  web.HTMLVideoElement? _videoElement;
  String? _blobUrl;

  bool _isInitialized = false;
  bool _isBuffering = true;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  Timer? _positionTimer;
  bool _viewFactoryRegistered = false;

  WebPlatformVideoPlayer({
    required this.videoService,
    required this.onStateChanged,
  });

  @override
  bool get isInitialized => _isInitialized;

  @override
  bool get isPlaying => _isPlaying;

  @override
  bool get isBuffering => _isBuffering;

  @override
  Duration get position => _position;

  @override
  Duration get duration => _duration;

  void _registerViewFactory() {
    if (_viewFactoryRegistered) return;
    _viewFactoryRegistered = true;

    ui_web.platformViewRegistry.registerViewFactory(_viewId, (int viewId) {
      final video = web.document.createElement('video') as web.HTMLVideoElement
        ..id = 'video-$_viewId'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.backgroundColor = 'black'
        ..style.objectFit = 'cover'
        ..controls = false
        ..autoplay = false
        ..playsInline = true;

      _videoElement = video;

      video.onPlay.listen((_) {
        _isPlaying = true;
        onStateChanged();
      });

      video.onPause.listen((_) {
        _isPlaying = false;
        onStateChanged();
      });

      video.onWaiting.listen((_) {
        _isBuffering = true;
        onStateChanged();
      });

      video.onPlaying.listen((_) {
        _isBuffering = false;
        onStateChanged();
      });

      video.onCanPlay.listen((_) {
        _isBuffering = false;
        onStateChanged();
      });

      video.onLoadedMetadata.listen((_) {
        _duration = Duration(milliseconds: (video.duration * 1000).toInt());
        onStateChanged();
      });

      video.onDurationChange.listen((_) {
        if (!video.duration.isNaN && !video.duration.isInfinite) {
          _duration = Duration(milliseconds: (video.duration * 1000).toInt());
          onStateChanged();
        }
      });

      _startPositionTimer();

      Future.delayed(const Duration(milliseconds: 100), () {
        _initializeHls();
      });

      return video;
    });
  }

  void _startPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (_videoElement != null) {
        final newPosition = Duration(
          milliseconds: (_videoElement!.currentTime * 1000).toInt(),
        );
        if (newPosition != _position) {
          _position = newPosition;
          onStateChanged();
        }
      }
    });
  }

  @override
  Future<void> initialize(String videoUrl, String encryptionKey) async {
    try {
      final playbackInfo = await videoService.playVideo(
        videoUrl: videoUrl,
        key: encryptionKey,
      );

      final blob = web.Blob(
        [playbackInfo.m3u8Content.toJS].toJS,
        web.BlobPropertyBag(type: 'application/x-mpegURL'),
      );
      _blobUrl = web.URL.createObjectURL(blob);

      _registerViewFactory();

      _isInitialized = true;
      onStateChanged();
    } catch (e, stack) {
      debugPrint('[WebPlatformVideoPlayer] Error initializing playback: $e');
      debugPrint('[WebPlatformVideoPlayer] Stack trace: $stack');
    }
  }

  void _initializeHls() {
    if (_videoElement == null || _blobUrl == null) {
      return;
    }

    try {
      if (HlsJS.isSupported()) {
        _hls = HlsJS();

        _hls!.on(
          'hlsError',
          ((JSAny event, JSAny data) {
            final errorDetails = _jsonStringify(data);
            debugPrint('[WebPlatformVideoPlayer] HLS Error: $errorDetails');
          }).toJS,
        );

        _hls!.loadSource(_blobUrl!);
        _hls!.attachMedia(_videoElement!);
      } else {
        _videoElement!.src = _blobUrl!;
      }

      _isBuffering = false;
      onStateChanged();
    } catch (e) {
      debugPrint('[WebPlatformVideoPlayer] Error initializing HLS: $e');
    }
  }

  @override
  void play() {
    _videoElement?.play();
  }

  @override
  void pause() {
    _videoElement?.pause();
  }

  @override
  void seekTo(Duration position) {
    if (_videoElement != null) {
      _videoElement!.currentTime = position.inMilliseconds / 1000.0;
      _position = position;
      onStateChanged();
    }
  }

  @override
  void dispose() {
    _positionTimer?.cancel();
    _hls?.destroy();
    _hls = null;
    if (_blobUrl != null) {
      web.URL.revokeObjectURL(_blobUrl!);
      _blobUrl = null;
    }
    _videoElement = null;
  }

  @override
  Widget buildVideoWidget({required BoxFit fit}) {
    if (_videoElement != null) {
      _videoElement!.style.objectFit = fit == BoxFit.contain
          ? 'contain'
          : 'cover';
    }
    return HtmlElementView(viewType: _viewId);
  }

  web.HTMLVideoElement? get videoElement => _videoElement;
}

PlatformVideoPlayer createPlatformVideoPlayer({
  required VideoService videoService,
  required VoidCallback onStateChanged,
}) {
  return WebPlatformVideoPlayer(
    videoService: videoService,
    onStateChanged: onStateChanged,
  );
}
