import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/api/services/notification_service.dart';
import 'package:live_app/models/audio.dart';
import 'package:live_app/models/track_audio.dart';
import 'package:live_app/page/creator_detail_page.dart';
import 'package:live_app/provider/current_audio_provider.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/widgets/message/waveform_widget.dart';
import 'package:palette_generator_master/palette_generator_master.dart';

enum PlaybackMode { normal, loopOne, shuffle, repeatAll }

class TrackPlayerPage extends ConsumerStatefulWidget {
  final List<TrackAudio> tracks;
  final Audio audio;
  final int initialIndex;

  const TrackPlayerPage({
    super.key,
    required this.tracks,
    required this.audio,
    required this.initialIndex,
  });

  @override
  ConsumerState<TrackPlayerPage> createState() => _TrackPlayerPageState();
}

class _TrackPlayerPageState extends ConsumerState<TrackPlayerPage> {
  late AudioPlayer player;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  bool isPlaying = false;
  late int currentIndex;
  PlaybackMode playbackMode = PlaybackMode.normal;
  Color dominantColor = Colors.black;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlayerState>? _stateSubscription;
  StreamSubscription<void>? _completionSubscription;
  Timer? _pausedPollTimer;
  bool _hasSourceLoaded = false;
  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    player = ref.read(audioPlayerProvider);
    _durationSubscription = player.onDurationChanged.listen(
      (d) => mounted ? setState(() => duration = d) : null,
    );
    _positionSubscription = player.onPositionChanged.listen(
      (p) => mounted ? setState(() => position = p) : null,
    );
    _stateSubscription = player.onPlayerStateChanged.listen((state) async {
      if (!mounted) return;
      final playing = state == PlayerState.playing;
      setState(() => isPlaying = playing);
      if (playing) {
        _pausedPollTimer?.cancel();
        if (_hasSourceLoaded && duration == Duration.zero) {
          final d = await player.getDuration();
          if (d != null && mounted) setState(() => duration = d);
        }
      } else {
        _startPausedPolling();
      }
    });

    _completionSubscription = player.onPlayerComplete.listen((_) async {
      if (!mounted) return;
      if (playbackMode == PlaybackMode.loopOne) {
        _playTrack(widget.tracks[currentIndex]);
      } else if (playbackMode == PlaybackMode.shuffle) {
        currentIndex = (DateTime.now().millisecond) % widget.tracks.length;
        _playTrack(widget.tracks[currentIndex]);
      } else if (playbackMode == PlaybackMode.repeatAll) {
        if (currentIndex < widget.tracks.length - 1) {
          currentIndex++;
        } else {
          currentIndex = 0;
        }
        _playTrack(widget.tracks[currentIndex]);
      } else {
        if (mounted) {
          setState(() {
            isPlaying = false;
            position = Duration.zero;
          });
        }
        player.stop();
        await NotificationService.instance.clearAudioNotification();
      }
    });

    final coverUrl = widget.audio.s3CoverUrl;
    if (coverUrl.isNotEmpty) {
      _updatePalette(coverUrl);
    }

    player.getCurrentPosition().then((pos) async {
      final st = player.state;
      if (!mounted) return;
      if (pos == null || pos == Duration.zero) {
        _playTrack(widget.tracks[currentIndex]);
      } else {
        setState(() {
          position = pos;
          isPlaying = st == PlayerState.playing;
        });
        final d = await player.getDuration();
        if (d != null && mounted) setState(() => duration = d);
      }
      if (!isPlaying) _startPausedPolling();
    });
  }

  void _startPausedPolling() {
    _pausedPollTimer?.cancel();
    _pausedPollTimer = Timer.periodic(const Duration(milliseconds: 500), (
      _,
    ) async {
      try {
        final pos = await player.getCurrentPosition();
        if (pos != null && mounted) {
          setState(() => position = pos);
        }
        if (duration == Duration.zero) {
          final d = await player.getDuration();
          if (d != null && mounted) setState(() => duration = d);
        }
      } catch (_) {}
    });
  }

  Future<void> _updatePalette(String imageUrl) async {
    final PaletteGeneratorMaster paletteGenerator =
        await PaletteGeneratorMaster.fromImageProvider(NetworkImage(imageUrl));
    if (mounted) {
      setState(() {
        dominantColor = paletteGenerator.dominantColor?.color ?? Colors.black;
      });
    }
  }

  Future<void> _playTrack(TrackAudio track) async {
    if (!mounted) return;
    setState(() => position = Duration.zero);
    try {
      await player.stop();
      await NotificationService.instance.clearAudioNotification();
    } catch (_) {}
    await player.setSourceUrl(track.s3HlsUrl ?? track.audioFile);
    await NotificationService.instance.showAudioNotification(
      track.title,
      track.description,
      payload:
          "route:/TrackPlayerPage?trackId=${track.id}&initialIndex=$currentIndex",
    );
    _hasSourceLoaded = true;
    final d = await player.getDuration();
    if (d != null && mounted) setState(() => duration = d);
    await player.resume();
    if (mounted) setState(() => isPlaying = true);
    ref.read(currentAudioProvider.notifier).state = widget.audio;
    _pausedPollTimer?.cancel();
  }

  bool _isDark(Color color) {
    return color.computeLuminance() < 0.5;
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _stateSubscription?.cancel();
    _completionSubscription?.cancel();
    _pausedPollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final track = widget.tracks[currentIndex];
    final theme = Theme.of(context);
    String translate(String key) =>
        ref.read(i18nNotifierProvider.notifier).translate(key);
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        forceMaterialTransparency: true,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: _isDark(dominantColor) ? Colors.white : Colors.black,
        ),
        titleTextStyle: TextStyle(
          color: _isDark(dominantColor) ? Colors.white : Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.queue_music),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                barrierColor: const Color.fromARGB(56, 96, 125, 139),
                backgroundColor: Colors.black,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (_) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 4,
                        width: 40,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: widget.tracks.length,
                          itemBuilder: (context, index) {
                            final t = widget.tracks[index];
                            return ListTile(
                              leading: const Icon(
                                Icons.music_note,
                                color: Colors.white70,
                              ),
                              title: Text(
                                t.title,
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                t.description,
                                style: const TextStyle(color: Colors.white70),
                              ),
                              selected: index == currentIndex,
                              selectedTileColor: Colors.white12,
                              onTap: () {
                                Navigator.pop(context);
                                currentIndex = index;
                                _playTrack(widget.tracks[currentIndex]);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {
              showDialog(
                context: context,
                barrierColor: const Color.fromARGB(56, 96, 125, 139),
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.black,
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Image.network(
                              widget.audio.s3CoverUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (widget.audio.album != null) ...[
                          if (widget.audio.titles.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    widget.audio.titles[0].title,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    widget.audio.titles[0].description,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          if (widget.audio.creatorObj != null)
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CreatorDetailPage(
                                      creatorName:
                                          widget.audio.creatorObj!.name,
                                      creatorId: widget.audio.creatorObj!.id,
                                      creatorAvatar:
                                          widget.audio.creatorObj!.avatar ?? "",
                                      items: [widget.audio],
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundImage: NetworkImage(
                                      widget.audio.creatorObj!.avatar ?? "",
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    widget.audio.creatorObj!.name,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.music_note,
                                    color: Colors.white70,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          track.title,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          track.description,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        translate("close"),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [dominantColor.withAlpha(200), Colors.black],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              SizedBox(height: kToolbarHeight * 2),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  widget.audio.s3CoverUrl,
                  height: 280,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                track.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                track.description,
                style: const TextStyle(fontSize: 16, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              WaveformSlider(
                progress: duration.inMilliseconds > 0
                    ? (position.inMilliseconds / duration.inMilliseconds).clamp(
                        0.0,
                        1.0,
                      )
                    : 0.0,
                height: 50,
                activeColor: Colors.white,
                inactiveColor: Colors.white12,
                onSeek: (progress) {
                  final seekTo = duration.inMilliseconds * progress;
                  player.seek(Duration(milliseconds: seekTo.toInt()));
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _format(position),
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    _format(duration),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _controlButton(Icons.skip_previous, () {
                    if (playbackMode == PlaybackMode.shuffle) {
                      currentIndex =
                          (DateTime.now().second) % widget.tracks.length;
                    } else if (playbackMode == PlaybackMode.loopOne) {
                    } else {
                      if (currentIndex > 0) {
                        currentIndex--;
                      } else {
                        currentIndex = widget.tracks.length - 1;
                      }
                    }
                    _playTrack(widget.tracks[currentIndex]);
                  }),

                  _controlButton(
                    isPlaying ? Icons.pause_circle : Icons.play_circle,
                    () {
                      if (!isPlaying) {
                        if (playbackMode == PlaybackMode.normal &&
                            position >= duration &&
                            duration > Duration.zero) {
                          _playTrack(widget.tracks[currentIndex]);
                        } else {
                          if (mounted) setState(() => isPlaying = true);
                          player.resume();
                        }
                        ref.read(audioPlayerProvider);
                      } else {
                        if (mounted) setState(() => isPlaying = false);
                        player.pause();
                        ref.read(audioPlayerProvider);
                      }
                    },
                    size: 64,
                    color: Colors.white,
                  ),
                  _controlButton(Icons.skip_next, () {
                    if (playbackMode == PlaybackMode.shuffle) {
                      currentIndex =
                          (DateTime.now().millisecond) % widget.tracks.length;
                    } else if (playbackMode == PlaybackMode.loopOne) {
                    } else {
                      if (currentIndex < widget.tracks.length - 1) {
                        currentIndex++;
                      } else {
                        currentIndex = 0;
                      }
                    }
                    _playTrack(widget.tracks[currentIndex]);
                  }),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.onSecondary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.lyrics, color: Colors.white),
                      label: Text(
                        translate("lyrics"),
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            backgroundColor: Colors.black,
                            title: Text(
                              translate("lyrics"),
                              style: TextStyle(color: Colors.white),
                            ),
                            content: Text(
                              track.lyrics ?? translate("noLyricsAvailable."),
                              style: const TextStyle(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  translate("close"),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 12),
                  IconButton(
                    icon: Icon(
                      playbackMode == PlaybackMode.normal
                          ? Icons.pause_circle_outline
                          : playbackMode == PlaybackMode.loopOne
                          ? Icons.repeat_one
                          : playbackMode == PlaybackMode.shuffle
                          ? Icons.shuffle
                          : Icons.repeat,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (mounted) {
                        setState(() {
                          if (playbackMode == PlaybackMode.normal) {
                            playbackMode = PlaybackMode.loopOne;
                          } else if (playbackMode == PlaybackMode.loopOne) {
                            playbackMode = PlaybackMode.shuffle;
                          } else if (playbackMode == PlaybackMode.shuffle) {
                            playbackMode = PlaybackMode.repeatAll;
                          } else {
                            playbackMode = PlaybackMode.normal;
                          }
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _controlButton(
    IconData icon,
    VoidCallback onPressed, {
    double size = 40,
    Color color = Colors.white,
  }) {
    return IconButton(
      icon: Icon(icon, size: size, color: color),
      onPressed: onPressed,
    );
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }
}
