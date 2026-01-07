import 'package:flutter/material.dart';

import '../../api/services/video_service.dart';

export 'short_video_item_stub.dart' show PlatformVideoPlayer;

abstract class PlatformVideoPlayer {
  bool get isInitialized;
  bool get isPlaying;
  bool get isBuffering;
  Duration get position;
  Duration get duration;

  Future<void> initialize(String videoUrl, String encryptionKey);
  void play();
  void pause();
  void seekTo(Duration position);
  void dispose();
  Widget buildVideoWidget({required BoxFit fit});
}

PlatformVideoPlayer createPlatformVideoPlayer({
  required VideoService videoService,
  required VoidCallback onStateChanged,
}) {
  throw UnsupportedError(
    'Cannot create video player without dart:io or dart:html',
  );
}
