import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class MobileVideoControlsOverlay extends StatefulWidget {
  final Player player;
  final VideoController controller;

  const MobileVideoControlsOverlay({
    super.key,
    required this.player,
    required this.controller,
  });

  @override
  State<MobileVideoControlsOverlay> createState() => _MobileVideoControlsOverlayState();
}

class _MobileVideoControlsOverlayState extends State<MobileVideoControlsOverlay> {
  double _volume = 1.0;
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
    if (isFullscreen) {
     
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } else {
      
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }

    setState(() {
      isFullscreen = !isFullscreen;
    });
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
                    userHasSeeked =
                        true; 
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

              Spacer(),
              PopupMenuButton<double>(
                color: Color(0x00000000),
                menuPadding: EdgeInsetsGeometry.all(0.0),
                icon: GestureDetector(
                  onDoubleTap: () {
                    setState(() {
                      _volume = _volume == 0 ? 1.0 : 0.0;
                      widget.player.setVolume(_volume);
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
                                  widget.player.setVolume(newVolume);
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
                                  widget.player.setVolume(newVolume);
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
                  isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                  color: Colors.white,
                ),
                onPressed: toggleFullscreen,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
