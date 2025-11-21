import 'package:flutter/material.dart';
import 'package:live_app/widgets/video/mobile_video_controls_overlay.dart';
import 'package:live_app/widgets/video/mobile_video_interaction_layer.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class MobileVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const MobileVideoPlayer({super.key, required this.videoUrl});

  @override
  State<MobileVideoPlayer> createState() => _MobileVideoPlayerState();
}

class _MobileVideoPlayerState extends State<MobileVideoPlayer> {
  late final Player player;
  late final VideoController controller;

  @override
  void initState() {
    super.initState();
    player = Player();
    controller = VideoController(player);
    player.open(Media(widget.videoUrl));
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Video(controller: controller, controls: null),
          MobileVideoInteractionLayer(player: player),
          MobileVideoControlsOverlay(player: player, controller: controller),
        ],
      ),
    );
  }
}
