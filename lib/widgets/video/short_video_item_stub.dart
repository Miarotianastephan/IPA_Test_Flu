import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../api/services/video_service.dart';

export 'short_video_item_stub.dart' show PlatformVideoPlayer;

abstract class PlatformVideoPlayer {
  ValueListenable<bool> get isInitializedListenable;
  ValueListenable<bool> get isPlayingListenable;
  ValueListenable<bool> get isBufferingListenable;
  ValueListenable<bool> get isMutedListenable;
  ValueListenable<Duration> get positionListenable;

  Future<void> initialize(
    String m3u8Content,
    String videoUrl,
    String encryptionKey, {
    String? videoId,
  });

  Future<void> initializeDirect(String videoUrl);

  void play();

  void pause();

  void seekTo(Duration position);

  void setMuted(bool muted);

  void dispose();

  Widget buildVideoWidget({required BoxFit fit});
}

PlatformVideoPlayer createPlatformVideoPlayer({
  required VoidCallback onLoaded,
  required VoidCallback onPlay,
  required VoidCallback onPause,
  required VoidCallback onMute,
  Function(int watchDuration, int videoDuration)?
  onWatchPercentReached,
}) {
  throw UnsupportedError(
    'Cannot create video player without dart:io or dart:html',
  );
}
