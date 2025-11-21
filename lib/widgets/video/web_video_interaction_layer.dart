import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:live_app/widgets/video/video_overlay_icon.dart';


class WebVideoInteractionLayer extends StatefulWidget {
  final FlickManager flickManager;

  const WebVideoInteractionLayer({super.key, required this.flickManager});

  @override
  State<WebVideoInteractionLayer> createState() => _WebVideoInteractionLayerState();
}

class _WebVideoInteractionLayerState extends State<WebVideoInteractionLayer> {
  Timer? rewindTimer;
  bool isRewinding = false;
  bool isForwarding = false;

  void startRewind() {
    final controller =
        widget.flickManager.flickVideoManager!.videoPlayerController;
    widget.flickManager.flickControlManager?.play();
    rewindTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      final current = controller!.value.position;
      final rewinded = current - const Duration(milliseconds: 800);
      controller.seekTo(rewinded > Duration.zero ? rewinded : Duration.zero);
    });
  }

  void stopRewind() {
    rewindTimer?.cancel();
  }

  void setSpeed(double speed) {
    final controller =
        widget.flickManager.flickVideoManager!.videoPlayerController;
    controller!.setPlaybackSpeed(speed);
    widget.flickManager.flickControlManager?.play();
  }

  @override
  void dispose() {
    rewindTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onLongPressStart: (_) {
              isRewinding = true;
              startRewind();
              setState(() {});
            },
            onLongPressEnd: (_) {
              isRewinding = false;
              stopRewind();
              setState(() {});
            },
            onDoubleTap: widget.flickManager.flickControlManager?.togglePlay,
            child: VideoOverlayIcon(
              visible: isRewinding,
              icon: Icons.fast_rewind,
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onLongPressStart: (_) {
              isForwarding = true;
              setSpeed(6.0);
              setState(() {});
            },
            onLongPressEnd: (_) {
              isForwarding = false;
              setSpeed(1.0);
              setState(() {});
            },
            onDoubleTap: widget.flickManager.flickControlManager?.togglePlay,
            child: VideoOverlayIcon(
              visible: isForwarding,
              icon: Icons.fast_forward,
            ),
          ),
        ),
      ],
    );
  }
}
