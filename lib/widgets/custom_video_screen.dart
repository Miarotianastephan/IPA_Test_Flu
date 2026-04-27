import 'package:flutter/material.dart';
import 'package:live_app/widgets/video_screen.dart';
import 'package:live_app/widgets/video/encrypted_hls_player.dart';
import 'package:live_app/widgets/video/mobile_video_player.dart';

class CustomVideoScreen extends StatefulWidget {
  final String? videoUrl;
  final String? localPath;
  final String? encryptionKey;
  final String? videoId;
  final bool autoPlay;
  final Function(EncryptedHlsPlayerController?)? onEncryptedControllerReady;

  const CustomVideoScreen({
    super.key,
    this.videoUrl,
    this.localPath,
    this.encryptionKey,
    this.videoId,
    this.autoPlay = true,
    this.onEncryptedControllerReady,
  });

  @override
  State<CustomVideoScreen> createState() => _CustomVideoScreenState();
}

class _CustomVideoScreenState extends State<CustomVideoScreen> {
  EncryptedHlsPlayerController? _encryptedController;

  @override
  void initState() {
    super.initState();
    if (widget.encryptionKey != null) {
      _encryptedController = EncryptedHlsPlayerController();
      widget.onEncryptedControllerReady?.call(_encryptedController);
    }
  }

  @override
  Widget build(BuildContext context) {
    return VideoScreen(
      videoUrl: widget.videoUrl,
      localPath: widget.localPath,
      encryptionKey: widget.encryptionKey,
      videoId: widget.videoId,
      autoPlay: widget.autoPlay,
      controller: widget.encryptionKey != null ? null : VideoScreenController(),
    );
  }
}
