import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/api/services/notification_service.dart';
import 'package:live_app/models/audio.dart';
import 'package:live_app/models/track_audio.dart';
import 'package:live_app/provider/current_audio_provider.dart';
import 'package:live_app/widgets/auto_scroll_text.dart';
import 'package:palette_generator_master/palette_generator_master.dart';

class MiniPlayerBar extends ConsumerStatefulWidget {
  final List<TrackAudio> tracks;
  final Audio currentAudio;
  final int initialIndex;
  final VoidCallback onClose;

  const MiniPlayerBar({
    super.key,
    required this.tracks,
    required this.currentAudio,
    required this.initialIndex,
    required this.onClose,
  });

  @override
  ConsumerState<MiniPlayerBar> createState() => _MiniPlayerBarState();
}

class _MiniPlayerBarState extends ConsumerState<MiniPlayerBar> {
  Color dominantColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _updatePalette(widget.currentAudio.s3CoverUrl);
  }

  Future<void> _updatePalette(String imageUrl) async {
    try {
      final PaletteGeneratorMaster paletteGenerator =
          await PaletteGeneratorMaster.fromImageProvider(
            NetworkImage(imageUrl),
          );
      setState(() {
        dominantColor = paletteGenerator.dominantColor?.color ?? Colors.white;
      });
    } catch (e) {
      debugPrint("Palette error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.read(audioPlayerProvider);
    final playerState = ref.watch(playerStateProvider).value;
    final isPlaying = playerState == PlayerState.playing;
    final track = widget.tracks[widget.initialIndex];

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: const BorderRadius.all(Radius.circular(15.0)),
          border: Border(
            left: BorderSide(color: dominantColor, width: 2),
            right: BorderSide(color: dominantColor, width: 2),
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.currentAudio.s3CoverUrl,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AutoScrollText(
                    text: track.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AutoScrollText(
                    text: track.description,
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                isPlaying ? Icons.pause_circle : Icons.play_circle,
                color: Colors.white,
              ),
              onPressed: () async {
                if (isPlaying) {
                  await player.pause();
                } else {
                  await player.resume();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.stop, color: Colors.white),
              onPressed: () async {
                await player.stop();
                ref.read(currentAudioProvider.notifier).state = null;
                await NotificationService.instance.clearAudioNotification();
              },
            ),
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.white),
              onPressed: () async {
                ref.read(currentAudioProvider.notifier).state = null;
                widget.onClose();
              },
            ),
          ],
        ),
      ),
    );
  }
}
