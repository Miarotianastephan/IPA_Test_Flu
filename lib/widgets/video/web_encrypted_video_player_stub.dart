import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/widgets/video/mobile_video_player.dart';

class WebEncryptedVideoPlayer extends ConsumerWidget {
  final String videoUrl;
  final String encryptionKey;
  final String videoId;
  final VideoScreenController? controller;
  final ValueNotifier<bool>? playingNotifier;

  const WebEncryptedVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.encryptionKey,
    required this.videoId,
    this.controller,
    this.playingNotifier,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    throw UnsupportedError('WebEncryptedVideoPlayer is only supported on web');
  }
}

class WebAdVideoPlayer extends ConsumerWidget {
  final String videoUrl;
  final String encryptionKey;
  final String videoId;
  final VoidCallback? onVideoEnded;

  const WebAdVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.encryptionKey,
    required this.videoId,
    this.onVideoEnded,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    throw UnsupportedError('WebAdVideoPlayer is only supported on web');
  }
}
