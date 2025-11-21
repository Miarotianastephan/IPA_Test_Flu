import 'dart:async';
import 'package:flutter/material.dart';
import 'package:live_app/widgets/video/video_overlay_icon.dart';
import 'package:media_kit/media_kit.dart';

class MobileVideoInteractionLayer extends StatefulWidget {
  final Player player;

  const MobileVideoInteractionLayer({super.key, required this.player});

  @override
  State<MobileVideoInteractionLayer> createState() =>
      _MobileVideoInteractionLayerState();
}

class _MobileVideoInteractionLayerState extends State<MobileVideoInteractionLayer> {
  Timer? rewindTimer;
  bool isRewinding = false;
  bool isForwarding = false;

  void startRewind() {
    rewindTimer = Timer.periodic(const Duration(milliseconds: 100), (_) async {
      final current = widget.player.state.position;
      final rewinded = current - const Duration(milliseconds: 800);
      widget.player.seek(rewinded > Duration.zero ? rewinded : Duration.zero);
    });
  }

  void togglePlay(Player player) {
    player.state.playing ? player.pause() : player.play();
  }

  void stopRewind() {
    rewindTimer?.cancel();
  }

  void setSpeed(double speed) {
    widget.player.setRate(speed);
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
            onDoubleTap: () => togglePlay(widget.player),
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
            onDoubleTap: () => togglePlay(widget.player),
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
