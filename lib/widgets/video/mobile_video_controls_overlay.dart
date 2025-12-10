import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:live_app/provider/video_detail_provider.dart';

class MobileVideoControlsOverlay extends ConsumerStatefulWidget {
  final bool useMediaKit;
  final Player? player;
  final VideoPlayerController? videoController;
  final ChewieController? chewieController;

  const MobileVideoControlsOverlay({
    super.key,
    required this.useMediaKit,
    this.player,
    this.videoController,
    this.chewieController,
  });

  @override
  ConsumerState<MobileVideoControlsOverlay> createState() =>
      _MobileVideoControlsOverlayState();
}

class _MobileVideoControlsOverlayState
    extends ConsumerState<MobileVideoControlsOverlay> {
  double _volume = 1.0;
  bool isFullscreen = false;

  Future<void> seekBackward() async {
    if (widget.useMediaKit && widget.player != null) {
      final pos = widget.player!.state.position;
      widget.player!.seek(pos - const Duration(seconds: 10));
    } else if (widget.chewieController != null) {
      final controller = widget.chewieController!.videoPlayerController;
      final pos = controller.value.position;
      final newPos = pos - const Duration(seconds: 10);
      controller.seekTo(newPos > Duration.zero ? newPos : Duration.zero);
    } else if (widget.videoController != null) {
      final pos = widget.videoController!.value.position;
      final newPos = pos - const Duration(seconds: 10);
      widget.videoController!.seekTo(
        newPos > Duration.zero ? newPos : Duration.zero,
      );
    }
  }

  Future<void> seekForward() async {
    if (widget.useMediaKit && widget.player != null) {
      final pos = widget.player!.state.position;
      widget.player!.seek(pos + const Duration(seconds: 10));
    } else if (widget.chewieController != null) {
      final controller = widget.chewieController!.videoPlayerController;
      final pos = controller.value.position;
      final dur = controller.value.duration;
      final newPos = pos + const Duration(seconds: 10);
      controller.seekTo(newPos > dur ? dur : newPos);
    } else if (widget.videoController != null) {
      final pos = widget.videoController!.value.position;
      final dur = widget.videoController!.value.duration;
      final newPos = pos + const Duration(seconds: 10);
      widget.videoController!.seekTo(newPos > dur ? dur : newPos);
    }
  }

  Future<void> toggleFullscreen() async {
    if (isFullscreen) {
      setState(() => isFullscreen = false);
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      ref.read(fullscreenProvider.notifier).state = false;
    } else {
      setState(() => isFullscreen = true);
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      ref.read(fullscreenProvider.notifier).state = true;
    }
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final m = two(d.inMinutes.remainder(60));
    final s = two(d.inSeconds.remainder(60));
    return '$m:$s';
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    if (widget.useMediaKit) {
      widget.player?.dispose();
    } else {
      widget.videoController?.dispose();
      widget.chewieController?.dispose();
    }
    super.dispose();
  }

  Widget buildSlider() {
    if (widget.useMediaKit && widget.player != null) {
      return StreamBuilder<Duration>(
        stream: widget.player!.stream.position,
        builder: (_, snapshot) {
          final pos = snapshot.data ?? Duration.zero;
          final dur = widget.player!.state.duration;
          return Slider(
            activeColor: Colors.blueAccent,
            inactiveColor: Colors.white,
            value: pos.inSeconds.toDouble(),
            min: 0,
            max: dur.inSeconds.toDouble(),
            onChanged: (value) {
              widget.player!.seek(Duration(seconds: value.toInt()));
            },
          );
        },
      );
    } else if (widget.chewieController != null) {
      final controller = widget.chewieController!.videoPlayerController;
      return ValueListenableBuilder<VideoPlayerValue>(
        valueListenable: controller,
        builder: (_, value, __) {
          return Slider(
            activeColor: Colors.blueAccent,
            inactiveColor: Colors.white,
            value: value.position.inSeconds.toDouble(),
            min: 0,
            max: value.duration.inSeconds.toDouble(),
            onChanged: (seconds) {
              controller.seekTo(Duration(seconds: seconds.toInt()));
            },
          );
        },
      );
    } else if (widget.videoController != null) {
      final controller = widget.videoController!;
      return ValueListenableBuilder<VideoPlayerValue>(
        valueListenable: controller,
        builder: (_, value, __) {
          return Slider(
            activeColor: Colors.blueAccent,
            inactiveColor: Colors.white,
            value: value.position.inSeconds.toDouble(),
            min: 0,
            max: value.duration.inSeconds.toDouble(),
            onChanged: (seconds) {
              controller.seekTo(Duration(seconds: seconds.toInt()));
            },
          );
        },
      );
    }
    return const SizedBox.shrink();
  }

  Widget buildPlayPause() {
    if (widget.useMediaKit && widget.player != null) {
      return StreamBuilder<bool>(
        stream: widget.player!.stream.playing,
        builder: (_, snapshot) {
          final isPlaying = snapshot.data ?? widget.player!.state.playing;
          return IconButton(
            icon: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: () =>
                isPlaying ? widget.player!.pause() : widget.player!.play(),
          );
        },
      );
    } else if (widget.chewieController != null) {
      final controller = widget.chewieController!.videoPlayerController;
      return ValueListenableBuilder<VideoPlayerValue>(
        valueListenable: controller,
        builder: (_, value, __) {
          return IconButton(
            icon: Icon(
              value.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: () =>
                value.isPlaying ? controller.pause() : controller.play(),
          );
        },
      );
    } else if (widget.videoController != null) {
      final controller = widget.videoController!;
      return ValueListenableBuilder<VideoPlayerValue>(
        valueListenable: controller,
        builder: (_, value, __) {
          return IconButton(
            icon: Icon(
              value.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: () =>
                value.isPlaying ? controller.pause() : controller.play(),
          );
        },
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(bottom: 30, left: 0, right: 0, child: buildSlider()),

        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildPlayPause(),
              widget.useMediaKit && widget.player != null
                  ? StreamBuilder<Duration>(
                      stream: widget.player!.stream.position,
                      builder: (_, snapshot) {
                        final pos = snapshot.data ?? Duration.zero;
                        final dur = widget.player!.state.duration;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "${_formatDuration(pos)} / ${_formatDuration(dur)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    )
                  : ValueListenableBuilder<VideoPlayerValue>(
                      valueListenable:
                          widget.videoController ??
                          widget.chewieController?.videoPlayerController ??
                          ValueNotifier(VideoPlayerValue.uninitialized()),
                      builder: (_, value, __) {
                        final position = value.position;
                        final duration = value.duration;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "${_formatDuration(position)} / ${_formatDuration(duration)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
              IconButton(
                icon: const Icon(Icons.replay_10, color: Colors.white),
                onPressed: seekBackward,
              ),
              IconButton(
                icon: const Icon(Icons.forward_10, color: Colors.white),
                onPressed: seekForward,
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  _volume == 0 ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _volume = _volume == 0 ? 1.0 : 0.0;
                    if (widget.useMediaKit && widget.player != null) {
                      widget.player!.setVolume(_volume * 100);
                    } else if (widget.chewieController != null) {
                      widget.chewieController!.videoPlayerController.setVolume(
                        _volume,
                      );
                    } else if (widget.videoController != null) {
                      widget.videoController!.setVolume(_volume);
                    }
                  });
                },
              ),
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
        Positioned.fill(
          child: widget.useMediaKit
              ? StreamBuilder<bool>(
                  stream: widget.player!.stream.buffering,
                  builder: (_, snapshot) {
                    final isBuffering = snapshot.data ?? false;
                    final hasDuration =
                        widget.player!.state.duration > Duration.zero;
                    if (isBuffering || !hasDuration) {
                      return const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                )
              : ValueListenableBuilder<VideoPlayerValue>(
                  valueListenable:
                      widget.videoController ??
                      widget.chewieController?.videoPlayerController ??
                      ValueNotifier(VideoPlayerValue.uninitialized()),
                  builder: (_, value, __) {
                    if (value.isBuffering || !value.isInitialized) {
                      return const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
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
