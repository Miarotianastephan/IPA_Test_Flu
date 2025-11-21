import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class WebVideoControlsOverlay extends StatefulWidget {
  final FlickManager flickManager;

  const WebVideoControlsOverlay({super.key, required this.flickManager});

  @override
  State<WebVideoControlsOverlay> createState() => _WebVideoControlsOverlayState();
}

class _WebVideoControlsOverlayState extends State<WebVideoControlsOverlay> {
  double _volume = 1.0;

  @override
  Widget build(BuildContext context) {
    final controller =
        widget.flickManager.flickVideoManager?.videoPlayerController;

    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox();
    }

    return Stack(
      children: [
        Positioned(
          bottom: 45,
          left: 0,
          right: 0,
          child: VideoProgressIndicator(
            controller,
            allowScrubbing: true,
            padding: const EdgeInsets.symmetric(
              vertical: 4.0,
              horizontal: 10.0,
            ),
            colors: const VideoProgressColors(
              playedColor: Colors.red,
              bufferedColor: Colors.grey,
              backgroundColor: Colors.black26,
            ),
          ),
        ),

        Positioned(
          bottom: 0,
          left: 16,
          right: 16,
          child: Row(
            children: [
              ValueListenableBuilder<VideoPlayerValue>(
                valueListenable: controller,
                builder: (_, value, __) {
                  final pos = value.position;
                  final dur = value.duration;
                  final posMin = pos.inMinutes
                      .remainder(60)
                      .toString()
                      .padLeft(2, '0');
                  final posSec = pos.inSeconds
                      .remainder(60)
                      .toString()
                      .padLeft(2, '0');
                  final durMin = dur.inMinutes
                      .remainder(60)
                      .toString()
                      .padLeft(2, '0');
                  final durSec = dur.inSeconds
                      .remainder(60)
                      .toString()
                      .padLeft(2, '0');

                  return Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          value.isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                        ),
                        onPressed:
                            widget.flickManager.flickControlManager?.togglePlay,
                      ),
                      Text(
                        '$posMin:$posSec / $durMin:$durSec',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  );
                },
              ),

              IconButton(
                icon: const Icon(Icons.replay_10, color: Colors.white),
                onPressed: () {
                  final current = controller.value.position;
                  controller.seekTo(current - const Duration(seconds: 10));
                },
              ),

              IconButton(
                icon: const Icon(Icons.forward_10, color: Colors.white),
                onPressed: () {
                  final current = controller.value.position;
                  controller.seekTo(current + const Duration(seconds: 10));
                },
              ),

              Spacer(),
              PopupMenuButton<double>(
                color: Color(0x00000000),
                menuPadding: EdgeInsetsGeometry.all(0.0),
                icon: GestureDetector(
                  onDoubleTap: () {
                    setState(() {
                      _volume = _volume == 0 ? 1.0 : 0.0;
                      controller.setVolume(_volume);
                    });
                  },
                  child: Icon(
                    _volume == 0 ? Icons.volume_off : Icons.volume_up,
                    color: Colors.white,
                  ),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    enabled: false,
                    child: StatefulBuilder(
                      builder: (context, setState) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove, color: Colors.black),
                                onPressed: () {
                                  double newVolume = (_volume - 0.1).clamp(
                                    0.0,
                                    1.0,
                                  );
                                  setState(() => _volume = newVolume);
                                  controller.setVolume(newVolume);
                                },
                              ),
                              Text(
                                '${(_volume * 100).toInt()}%',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.add, color: Colors.black),
                                onPressed: () {
                                  double newVolume = (_volume + 0.1).clamp(
                                    0.0,
                                    1.0,
                                  );
                                  setState(() => _volume = newVolume);
                                  controller.setVolume(newVolume);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              IconButton(
                icon: Icon(
                  widget.flickManager.flickControlManager?.isFullscreen == true
                      ? Icons.fullscreen_exit
                      : Icons.fullscreen,
                  color: Colors.white,
                ),
                onPressed: () {
                  widget.flickManager.flickControlManager?.toggleFullscreen();
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
