import 'package:flutter/material.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:live_app/widgets/video/web_video_controls_overlay.dart';
import 'package:live_app/widgets/video/web_video_interaction_layer.dart';
import 'package:video_player/video_player.dart';

class WebVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const WebVideoPlayer({super.key, required this.videoUrl});

  @override
  State<WebVideoPlayer> createState() => _WebVideoPlayerState();
}

class _WebVideoPlayerState extends State<WebVideoPlayer> {
  FlickManager? flickManager;

  @override
  void initState() {
    super.initState();

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );

    controller
        .initialize()
        .then((_) {
          flickManager = FlickManager(videoPlayerController: controller);

          if (mounted) setState(() {});
        })
        .catchError((e) {
          debugPrint(e);
        });
  }

  @override
  void dispose() {
    flickManager?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (flickManager == null ||
        !flickManager!.flickVideoManager!.isVideoInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final controller = flickManager!.flickVideoManager!.videoPlayerController;

    return AspectRatio(
      aspectRatio: controller!.value.aspectRatio,
      child: FlickVideoPlayer(
        flickManager: flickManager!,
        flickVideoWithControls: FlickVideoWithControls(
          videoFit: BoxFit.contain,
          controls: Stack(
            children: [
              WebVideoInteractionLayer(flickManager: flickManager!),
              WebVideoControlsOverlay(flickManager: flickManager!),
            ],
          ),
        ),
      ),
    );
  }
}
