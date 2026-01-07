import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/widgets/video/web_video_controls_overlay.dart';
import 'package:live_app/widgets/video/web_video_interaction_layer.dart';
import 'package:video_player/video_player.dart';

class WebVideoPlayer extends ConsumerStatefulWidget {
  final String videoUrl;

  const WebVideoPlayer({super.key, required this.videoUrl});

  @override
  ConsumerState<WebVideoPlayer> createState() => _WebVideoPlayerState();
}

class _WebVideoPlayerState extends ConsumerState<WebVideoPlayer> {
  FlickManager? flickManager;
  String? _error;

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
          debugPrint('[WebVideoPlayer] Error initializing controller: $e');
          if (mounted) {
            setState(() {
              _error = e.toString();
            });
          }
        });
  }

  @override
  void dispose() {
    flickManager?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(height: 8),
            Text(
              translate('unableToLoadVideo'),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              translate('checkConnectionAndRetry'),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ],
        ),
      );
    }

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
