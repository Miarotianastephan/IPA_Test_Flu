import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/audio.dart';

final currentAudioProvider = StateProvider<Audio?>((ref) => null);
final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  return AudioPlayer();
});
final playerStateProvider = StreamProvider<PlayerState>((ref) {
  final player = ref.read(audioPlayerProvider);
  return player.onPlayerStateChanged;
});
final showFloatingButtonProvider = StateProvider<bool>((ref) => false);
