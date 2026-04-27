import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/api/services/audio_service.dart';
import 'package:live_app/models/audio.dart';
import 'package:live_app/models/audio_category.dart';
import 'package:live_app/provider/api_provider.dart';

final audioServiceProvider = Provider<AudioService>((ref) {
  final client = ref.read(apiClientProvider);
  return AudioService(client);
});
final audioProvider = FutureProvider<List<Audio>>((ref) async {
  final service = ref.read(audioServiceProvider);
  final resp = await service.audios();

  if (resp.code != 1) {
    throw Exception('Erreur API: ${resp.code}');
  }

  return resp.data ?? [];
});
final audioCategoriesProvider = FutureProvider<List<AudioCategory>>((
  ref,
) async {
  final service = ref.read(audioServiceProvider);
  final resp = await service.audios();
  if (resp.code != 1) {
    throw Exception('Erreur API: ${resp.code}');
  }
  final list = resp.data ?? [];
  return list.map((a) {
    final cat = a.audioCategory;
    return AudioCategory(id: cat.id, name: cat.name);
  }).toList();
});
