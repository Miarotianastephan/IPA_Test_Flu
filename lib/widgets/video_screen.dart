import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:live_app/widgets/video/encrypted_hls_player.dart';
import 'package:live_app/widgets/video/mobile_video_player.dart';
import 'package:live_app/widgets/video/web_video_player.dart';
import 'package:live_app/widgets/video/web_encrypted_video_player_stub.dart'
    if (dart.library.html) 'package:live_app/widgets/video/web_encrypted_video_player.dart';

class VideoScreen extends StatefulWidget {
  final String? videoUrl;
  final String? localPath;
  final VideoScreenController? controller;

  final String? encryptionKey;

  const VideoScreen({
    super.key,
    this.videoUrl,
    this.localPath,
    this.controller,
    this.encryptionKey,
  });

  const VideoScreen.encrypted({
    super.key,
    required String this.videoUrl,
    required String this.encryptionKey,
    this.controller,
  }) : localPath = null;

  bool get isEncryptedHls => encryptionKey != null && videoUrl != null;

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      if (widget.isEncryptedHls) {
        return WebEncryptedVideoPlayer(
          videoUrl: widget.videoUrl!,
          encryptionKey: widget.encryptionKey!,
        );
      }
      return WebVideoPlayer(videoUrl: widget.videoUrl!);
    }

    if (widget.isEncryptedHls) {
      return EncryptedHlsPlayer(
        videoUrl: widget.videoUrl!,
        encryptionKey: widget.encryptionKey!,
        controller: widget.controller != null
            ? EncryptedHlsPlayerController()
            : null,
      );
    }

    return MobileVideoPlayer(
      videoUrl: widget.videoUrl,
      localPath: widget.localPath,
      controller: widget.controller,
    );
  }
}
