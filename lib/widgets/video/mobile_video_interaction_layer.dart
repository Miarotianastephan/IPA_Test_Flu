import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/video_playback_provider.dart';
import 'package:live_app/widgets/video/video_overlay_icon.dart';
import 'package:media_kit/media_kit.dart';
import 'package:chewie/chewie.dart';

class MobileVideoInteractionLayer extends ConsumerStatefulWidget {
  final bool useMediaKit;
  final Player? player;
  final ChewieController? chewieController;
  const MobileVideoInteractionLayer({
    super.key,
    required this.useMediaKit,
    this.player,
    this.chewieController,
  });
  @override
  ConsumerState<MobileVideoInteractionLayer> createState() =>
      _MobileVideoInteractionLayerState();
}

class _MobileVideoInteractionLayerState
    extends ConsumerState<MobileVideoInteractionLayer> {
  Timer? rewindTimer;
  bool isRewinding = false;
  bool isForwarding = false;

  void startRewind() {
    rewindTimer = Timer.periodic(const Duration(milliseconds: 100), (_) async {
      if (widget.useMediaKit && widget.player != null) {
        final current = widget.player!.state.position;
        final rewinded = current - const Duration(milliseconds: 800);
        widget.player!.seek(
          rewinded > Duration.zero ? rewinded : Duration.zero,
        );
      } else if (widget.chewieController != null) {
        final controller = widget.chewieController!.videoPlayerController;
        final current = controller.value.position;
        final rewinded = current - const Duration(milliseconds: 800);
        controller.seekTo(rewinded > Duration.zero ? rewinded : Duration.zero);
      }
    });
  }

  void togglePlay() {
    if (widget.useMediaKit && widget.player != null) {
      widget.player!.state.playing
          ? widget.player!.pause()
          : widget.player!.play();
      ref.read(videoPausedProvider.notifier).state =
          widget.player!.state.playing;
    } else if (widget.chewieController != null) {
      final controller = widget.chewieController!.videoPlayerController;
      controller.value.isPlaying ? controller.pause() : controller.play();
      ref.read(videoPausedProvider.notifier).state = controller.value.isPlaying;
    }
  }

  void stopRewind() {
    rewindTimer?.cancel();
  }

  void setSpeed(double speed) {
    if (widget.useMediaKit && widget.player != null) {
      widget.player!.setRate(speed);
    } else if (widget.chewieController != null) {
      final controller = widget.chewieController!.videoPlayerController;
      controller.setPlaybackSpeed(speed);
    }
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
              setSpeed(1.0);
              setState(() {});
            },
            onDoubleTap: togglePlay,
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
            onDoubleTap: togglePlay,
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
