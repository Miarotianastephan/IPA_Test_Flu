import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/change_notifier.dart';
import 'package:live_app/services/hls_proxy_server.dart';
import 'package:live_app/utils/percent_watch.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

import '../../api/services/video_service.dart';
import 'short_video_item_stub.dart';

export 'short_video_item_stub.dart' show PlatformVideoPlayer;

class MobilePlatformVideoPlayer implements PlatformVideoPlayer {
  final VoidCallback onLoaded;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final VoidCallback onMute;
  final Function(int watchDuration, int videoDuration)?
  onWatchPercentReached;

  bool _useMediaKit = false;
  bool _platformChecked = false;

  VideoPlayerController? _videoController;
  Player? _mediaKitPlayer;
  VideoController? _mediaKitController;
  StreamSubscription<bool>? _bufferingSubscription;
  StreamSubscription<bool>? _playingSubscription;

  final String _sessionId = const Uuid().v4();
  String? _proxyUrl;

  // bool _isInitialized = false;
  // bool _isBuffering = true;
  // bool _lastIsPlaying = false;

  MobilePlatformVideoPlayer({
    required this.onLoaded,
    required this.onPlay,
    required this.onPause,
    required this.onMute,
    this.onWatchPercentReached,
  });



  Duration? _totalDuration;
  bool _sentPercent = false;
  double percentWatch = PercentWatch.percent;

  // @override
  // bool get isPlaying {
  //   if (_useMediaKit) {
  //     return _mediaKitPlayer?.state.playing ?? false;
  //   }
  //   return _videoController?.value.isPlaying ?? false;
  // }

// @override
  // bool get isInitialized => _isInitialized;

  // @override
  // bool get isBuffering => _isBuffering;

  // @override
  // bool get isMuted => false;

  // @override
  // Duration get position {
  //   if (_useMediaKit) {
  //     return _mediaKitPlayer?.state.position ?? Duration.zero;
  //   }
  //   return _videoController?.value.position ?? Duration.zero;
  // }

  // @override
  // Duration get duration {
  //   if (_useMediaKit) {
  //     return _mediaKitPlayer?.state.duration ?? Duration.zero;
  //   }
  //   return _videoController?.value.duration ?? Duration.zero;
  // }



  final ValueNotifier<Duration> _positionNotifier = ValueNotifier(
    Duration.zero,
  );
  final ValueNotifier<bool> _playingNotifier = ValueNotifier(true);
  final ValueNotifier<bool> _initializedNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _bufferingNotifier = ValueNotifier(true);
  final ValueNotifier<bool> _mutedNotifier = ValueNotifier(false);

  Future<bool> _isHuaweiDevice() async {
    if (!Platform.isAndroid) return false;
    final info = await DeviceInfoPlugin().androidInfo;
    return info.manufacturer.toLowerCase() == 'huawei';
  }

  @override
  Future<void> initialize(
    String m3u8Content,
    String videoUrl,
    String encryptionKey, {
    String? videoId,
  }) async {
    try {
      if (!_platformChecked) {
        _useMediaKit = await _isHuaweiDevice();
        _platformChecked = true;
      }

      HlsProxyServer.instance.acquire();
      await HlsProxyServer.instance.start();



      _proxyUrl = HlsProxyServer.instance.registerPlaylist(
        _sessionId,
        m3u8Content,
        baseUrl: videoUrl,
      );

      if (_useMediaKit) {
        await _initializeMediaKit();
      } else {
        await _initializeVideoPlayer();
      }
    } catch (e) {}
  }

  @override
  Future<void> initializeDirect(String videoUrl) async {
    try {
      if (!_platformChecked) {
        _useMediaKit = await _isHuaweiDevice();
        _platformChecked = true;
      }

      _proxyUrl = videoUrl;

      if (_useMediaKit) {
        await _initializeMediaKit();
      } else {
        await _initializeVideoPlayer();
      }
    } catch (e) {}
  }

  Future<void> _initializeMediaKit() async {
    if (_proxyUrl == null) return;

    try {
      _mediaKitPlayer = Player();
      _mediaKitController = VideoController(_mediaKitPlayer!);

      _bufferingSubscription = _mediaKitPlayer!.stream.buffering.listen((
        isBuffering,
      ) {
        _bufferingNotifier.value  = isBuffering;
      });

      _playingSubscription = _mediaKitPlayer!.stream.playing.listen((isPlaying) {
        final last = _playingNotifier.value;
        _playingNotifier.value = isPlaying;

        if (isPlaying && !last) {
          onPlay();
        } else if (!isPlaying && last) {
          onPause();
        }
      });

      _mediaKitPlayer!.stream.duration.listen((duration) {
        _totalDuration = duration;
      });

      _mediaKitPlayer!.stream.position.listen((position) {
        _positionNotifier.value = position;

        if (_totalDuration != null &&
            position.inSeconds >= _totalDuration!.inSeconds * percentWatch &&
            !_sentPercent) {
          _sentPercent = true;

          if (onWatchPercentReached != null ) {
            onWatchPercentReached!(
              position.inSeconds,
              _totalDuration!.inSeconds,
            );
          }
        }
      });
      try {
        await _mediaKitPlayer!.open(Media(_proxyUrl!), play: false);
        _initializedNotifier.value = true;
        _bufferingNotifier.value  = false;
        onLoaded();
      } catch (e) {
        // Don't set _isInitialized on error
      }
    } catch (e) {
      // Clean up on error
      _bufferingSubscription?.cancel();
      _playingSubscription?.cancel();
      _mediaKitPlayer?.dispose();
      _mediaKitPlayer = null;
      _mediaKitController = null;
    }
  }

  Future<void> _initializeVideoPlayer() async {
    if (_proxyUrl == null) return;

    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(_proxyUrl!),
      );

      try {
        await _videoController!.initialize();
        _initializedNotifier.value = true;
        onLoaded();

        _videoController!.addListener(() {
          final value = _videoController!.value;
          _positionNotifier.value = value.position;

          bool changed = false;

          if (_bufferingNotifier.value != value.isBuffering) {
            _bufferingNotifier.value = value.isBuffering;
            changed = true;
          }

          final last = _playingNotifier.value;
          if (last != value.isPlaying) {
            _playingNotifier.value = value.isPlaying;
            if (value.isPlaying) {
              onPlay();
            } else {
              onPause();
            }
          }

          if (value.isInitialized && !_sentPercent) {
            final position = value.position.inSeconds;
            final duration = value.duration.inSeconds;

            if (position >= duration * percentWatch) {
              _sentPercent = true;

              if (onWatchPercentReached != null ) {
                onWatchPercentReached!(position, duration);
              }
            }
          }
        });

        _bufferingNotifier.value  = false;
      } catch (e) {
        // Clean up on error
        _videoController?.dispose();
        _videoController = null;
      }
    } catch (e) {}
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
  void setMuted(bool muted) {
    if (_mutedNotifier.value == muted) return;

    _mutedNotifier.value = muted;

    if (_useMediaKit) {
      _mediaKitPlayer?.setVolume(muted ? 0.0 : 1.0);
    } else {
      _videoController?.setVolume(muted ? 0.0 : 1.0);
    }

    if (muted) {
      onMute();
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
      _playingSubscription?.cancel();
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
    } else if (_videoController != null &&
        _videoController!.value.isInitialized) {
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
  Function(int watchDuration, int videoDuration)?
  onWatchPercentReached,
}) {
  return MobilePlatformVideoPlayer(
    onLoaded: onLoaded,
    onPlay: onPlay,
    onPause: onPause,
    onMute: onMute,
    onWatchPercentReached: onWatchPercentReached,
  );
}
