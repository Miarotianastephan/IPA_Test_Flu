import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/vip.dart';
import 'package:live_app/provider/behavior_tracker_provider.dart';
import 'package:live_app/widgets/video/encrypted_hls_player.dart';
import 'package:live_app/widgets/video/mobile_video_player.dart';
import 'package:live_app/widgets/video/web_video_player.dart';
import 'package:live_app/widgets/video/canvas_video_player_stub.dart'
    if (dart.library.html) 'package:live_app/widgets/video/canvas_video_player.dart';
import 'package:live_app/widgets/video/web_encrypted_video_player_stub.dart'
    if (dart.library.html) 'package:live_app/widgets/video/web_encrypted_video_player.dart';

class VideoScreen extends ConsumerStatefulWidget {
  final String? videoUrl;
  final String? localPath;
  final VideoScreenController? controller;
  final EncryptedHlsPlayerController? encryptedController;
  final ValueNotifier<bool>? playingNotifier;
  final Vip? vip;
  final bool autoPlay;
  final String? videoId;
  final String? encryptionKey;
  final bool useCanvasPlayer;

  const VideoScreen({
    super.key,
    this.videoUrl,
    this.localPath,
    this.controller,
    this.encryptedController,
    this.encryptionKey,
    this.playingNotifier,
    this.vip,
    this.autoPlay = true,
    this.videoId,
    this.useCanvasPlayer = false,
  });

  const VideoScreen.encrypted({
    super.key,
    required String this.videoUrl,
    required String this.encryptionKey,
    this.controller,
    this.encryptedController,
    this.playingNotifier,
    this.vip,
    this.autoPlay = true,
    this.videoId,
    this.useCanvasPlayer = false,
  }) : localPath = null;

  bool get isEncryptedHls => encryptionKey != null && videoUrl != null;

  @override
  ConsumerState<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends ConsumerState<VideoScreen> {
  @override
  void initState() {
    super.initState();
    widget.playingNotifier?.addListener(_onPlayingChanged);
  }

  @override
  void dispose() {
    widget.playingNotifier?.removeListener(_onPlayingChanged);
    super.dispose();
  }

  void _onPlayingChanged() {
    final isPlaying = widget.playingNotifier?.value ?? false;
    if (isPlaying) {
      ref.trackVideoWatch();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      if (widget.isEncryptedHls) {
        if (widget.useCanvasPlayer) {
          return CanvasVideoPlayer(
            videoUrl: widget.videoUrl!,
            encryptionKey: widget.encryptionKey!,
            videoId: widget.videoId!,
            controller: widget.controller,
            playingNotifier: widget.playingNotifier,
          );
        }
        return WebEncryptedVideoPlayer(
          videoUrl: widget.videoUrl!,
          encryptionKey: widget.encryptionKey!,
          videoId: widget.videoId!,
          controller: widget.controller,
          playingNotifier: widget.playingNotifier,
        );
      }
      return WebVideoPlayer(
        videoUrl: widget.videoUrl!,
        controller: widget.controller,
      );
    }

    if (widget.isEncryptedHls) {
      return EncryptedHlsPlayer(
        videoId: widget.videoId!,
        videoUrl: widget.videoUrl!,
        encryptionKey: widget.encryptionKey!,
        controller:
            widget.encryptedController ??
            (widget.controller != null ? EncryptedHlsPlayerController() : null),
        playingNotifier: widget.playingNotifier,
      );
    }

    return MobileVideoPlayer(
      videoUrl: widget.videoUrl,
      localPath: widget.localPath,
      controller: widget.controller,
      autoPlay: widget.autoPlay,
    );
  }
}
