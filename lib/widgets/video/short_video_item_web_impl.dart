import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/change_notifier.dart';
import 'package:live_app/utils/hls_video_utils.dart';
import 'package:uuid/uuid.dart';
import 'package:web/web.dart' as web;
import 'short_video_item_stub.dart';
export 'short_video_item_stub.dart' show PlatformVideoPlayer;

class WebPlatformVideoPlayer implements PlatformVideoPlayer {
  final VoidCallback onLoaded;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final VoidCallback onMute;
  final String _viewId = 'hls-short-video-${const Uuid().v4()}';
  HlsJS? _hls;
  web.HTMLVideoElement? _videoElement;
  String? _blobUrl;
  final Function(int watchDuration, int videoDuration)? onWatchPercentReached;

  Duration _position = Duration.zero;

  final ValueNotifier<Duration> _positionNotifier = ValueNotifier(
    Duration.zero,
  );
  final ValueNotifier<bool> _playingNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _initializedNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _bufferingNotifier = ValueNotifier(true);
  final ValueNotifier<bool> _mutedNotifier = ValueNotifier(true);

  bool _viewFactoryRegistered = false;

  WebPlatformVideoPlayer({
    required this.onLoaded,
    required this.onPlay,
    required this.onPause,
    required this.onMute,
    this.onWatchPercentReached,
  });

  void _registerViewFactory() {
    if (_viewFactoryRegistered) return;
    _viewFactoryRegistered = true;

    ui_web.platformViewRegistry.registerViewFactory(_viewId, (int viewId) {
      final video = web.document.createElement('video') as web.HTMLVideoElement
        ..id = 'video-$_viewId'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.backgroundColor = 'transparent'
        ..style.objectFit = 'cover'
        ..preload = "auto"
        ..crossOrigin = "anonymous"
        ..controls = false
        ..playsInline = true
        ..loop = true
        ..muted = _mutedNotifier.value;

      _videoElement = video;


      video.onPlay.listen((_) {
        _playingNotifier.value = true;
        onPlay();
      });

      video.onPause.listen((_) {
        _playingNotifier.value = false;
        onPause();
      });

      video.onWaiting.listen((_) {
        _bufferingNotifier.value = true;
      });

      video.onPlaying.listen((_) {
        _bufferingNotifier.value = false;
      });

      video.onCanPlay.listen((_) {
        _bufferingNotifier.value = false;
        onLoaded();
      });

      video.onError.listen((_) {
        final error = video.error;
        if (error != null) {
          debugPrint(
            '[DebugPlayer] Video error: code=${error.code}, message=${error.message}',
          );
        }
        _bufferingNotifier.value = false;
      });



      // 使用 onTimeUpdate 回调更新进度，不触发 onStateChanged
      video.onTimeUpdate.listen((_) {
        final newPosition = Duration(
          milliseconds: (video.currentTime * 1000).toInt(),
        );
        if (newPosition != _position) {
          _position = newPosition;
          _positionNotifier.value = newPosition;
        }
      });

      _initializeHls();
      return video;
    });
  }

  @override
  Future<void> initialize(
    String m3u8Content,
    String videoUrl,
    String encryptionKey, {
    String? videoId,
  }) async {
    try {
      final rewrittenM3u8 = rewriteM3u8WithAbsoluteUrls(m3u8Content, videoUrl);

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

      _registerViewFactory();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializedNotifier.value = true;
      });
    } catch (e) {
      debugPrint('[DebugPlayer] Error initializing video: $e');
    }
  }

  @override
  Future<void> initializeDirect(String videoUrl) async {
    try {
      _blobUrl = videoUrl;
      _registerViewFactory();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializedNotifier.value = true;
      });
    } catch (e) {}
  }

  void _initializeHls() {
    if (_videoElement == null || _blobUrl == null) {
      return;
    }

    try {
      final hlsSupported = HlsJS.isSupported();
      if (hlsSupported) {
        _hls = HlsJS();

        _hls!.on(
          'hlsError',
          ((JSAny event, JSAny data) {
            debugPrint('[DebugPlayer] HLS.js error occurred');
          }).toJS,
        );

        _hls!.loadSource(_blobUrl!);
        _hls!.attachMedia(_videoElement!);
      } else if (supportsNativeHls()) {
        _videoElement!.src = _blobUrl!;

        _videoElement!.load();
      } else {
        _videoElement!.src = _blobUrl!;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _bufferingNotifier.value = false;
      });
    } catch (e) {
      debugPrint('[DebugPlayer] Error initializing HLS: $e');
    }
  }



  @override
  void play() {
    _videoElement!.play().toDart.catchError((error){
      if (isIOS()) {
        setMuted(true);
        onMute();
      }
      _videoElement!.play().toDart.ignore();
    });
  }

  @override
  void pause() {
    _videoElement?.pause();
    _playingNotifier.value = false;
  }

  @override
  void seekTo(Duration position) {
    if (_videoElement != null) {
      _videoElement!.currentTime = position.inMilliseconds / 1000.0;
      _position = position;
      _positionNotifier.value = position;
    }
  }

  @override
  void setMuted(bool muted) {
    _mutedNotifier.value = muted;
    _videoElement?.muted = muted;
  }

  @override
  void dispose() {
    _hls?.destroy();
    _hls = null;
    if (_blobUrl != null && _blobUrl!.startsWith('blob:')) {
      web.URL.revokeObjectURL(_blobUrl!);
    }
    _blobUrl = null;
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

  @override
  ValueListenable<Duration> get positionListenable => _positionNotifier;

  @override
  ValueListenable<bool> get isInitializedListenable => _initializedNotifier;

  @override
  ValueListenable<bool> get isPlayingListenable => _playingNotifier;

  @override
  ValueListenable<bool> get isBufferingListenable => _bufferingNotifier;

  @override
  ValueListenable<bool> get isMutedListenable => _mutedNotifier;
}

PlatformVideoPlayer createPlatformVideoPlayer({
  required VoidCallback onLoaded,
  required VoidCallback onPlay,
  required VoidCallback onPause,
  required VoidCallback onMute,
  Function(int watchDuration, int videoDuration)? onWatchPercentReached,
}) {
  return WebPlatformVideoPlayer(
    onLoaded: onLoaded,
    onPlay: onPlay,
    onPause: onPause,
    onMute: onMute,
    onWatchPercentReached: onWatchPercentReached,
  );
}
