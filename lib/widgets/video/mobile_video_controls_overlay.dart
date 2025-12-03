import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/video_detail_provider.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class MobileVideoControlsOverlay extends ConsumerStatefulWidget {
  final Player player;
  final VideoController controller;

  const MobileVideoControlsOverlay({
    super.key,
    required this.player,
    required this.controller,
  });

  @override
  ConsumerState<MobileVideoControlsOverlay> createState() =>
      _MobileVideoControlsOverlayState();
}

class _MobileVideoControlsOverlayState
    extends ConsumerState<MobileVideoControlsOverlay> {
  double _volume = 100.0;
  bool userHasSeeked = false;
  bool isFullscreen = false;

  Future<void> seekBackward(Player player) async {
    final pos = player.state.position;
    player.seek(pos - const Duration(seconds: 10));
  }

  Future<void> seekForward(Player player) async {
    final pos = player.state.position;
    player.seek(pos + const Duration(seconds: 10));
  }

  @override
  void initState() {
    super.initState();
    widget.player.setVolume(_volume);
  }

  Future<void> toggleFullscreen() async {
    if (isFullscreen == true) {
      setState(() {
        isFullscreen = false;
      });
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      ref.read(fullscreenProvider.notifier).state = false;
    } else {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      ref.read(fullscreenProvider.notifier).state = true;
      setState(() {
        isFullscreen = true;
      });
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    widget.player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Barre de progression
        Positioned(
          bottom: 30,
          left: 0,
          right: 0,
          child: StreamBuilder<Duration>(
            stream: widget.player.stream.position,
            builder: (_, snapshot) {
              final pos = snapshot.data ?? Duration.zero;
              final dur = widget.player.state.duration;
              return Slider(
                activeColor: Colors.blueAccent,
                inactiveColor: Colors.white,
                value: pos.inSeconds.toDouble(),
                min: 0,
                max: dur.inSeconds.toDouble(),
                onChanged: (value) {
                  setState(() {
                    userHasSeeked = true;
                  });
                  widget.player.seek(Duration(seconds: value.toInt()));
                },
              );
            },
          ),
        ),

        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Row(
            children: [
              StreamBuilder<bool>(
                stream: widget.player.stream.playing,
                builder: (_, snapshot) {
                  final isPlaying = snapshot.data ?? false;
                  return IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    onPressed: () => isPlaying
                        ? widget.player.pause()
                        : widget.player.play(),
                  );
                },
              ),

              // Temps
              StreamBuilder<Duration>(
                stream: widget.player.stream.position,
                builder: (_, snapshot) {
                  final pos = snapshot.data ?? Duration.zero;
                  final dur = widget.player.state.duration;
                  String format(Duration d) =>
                      '${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';
                  return Text(
                    '${format(pos)} / ${format(dur)}',
                    style: const TextStyle(color: Colors.white),
                  );
                },
              ),

              IconButton(
                icon: const Icon(Icons.replay_10, color: Colors.white),
                onPressed: () => seekBackward(widget.player),
              ),
              IconButton(
                icon: const Icon(Icons.forward_10, color: Colors.white),
                onPressed: () => seekForward(widget.player),
              ),

              const Spacer(),

              // Volume
              IconButton(
                icon: Icon(
                  _volume == 0 ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _volume = _volume == 0 ? 100.0 : 0.0;
                    widget.player.setVolume(_volume);
                  });
                },
              ),

              // Fullscreen
              IconButton(
                icon: Icon(
                  isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                  color: Colors.white,
                ),
                onPressed: toggleFullscreen,
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          top: 0,
          child: StreamBuilder<bool>(
            stream: widget.player.stream.buffering,
            builder: (_, snapshot) {
              final isBuffering = snapshot.data ?? false;
              final hasDuration = widget.player.state.duration > Duration.zero;

              if (isBuffering || !hasDuration) {
                return IgnorePointer(
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}
