import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/api/services/manga_servicedart';
import 'package:live_app/models/manga.dart';
import 'package:live_app/models/manga_category.dart';
import 'package:live_app/provider/api_provider.dart';

final mangaServiceProvider = Provider<MangaService>((ref) {
  final client = ref.read(apiClientProvider);
  return MangaService(client);
});

final mangaProvider = FutureProvider<List<Manga>>((ref) async {
  final service = ref.read(mangaServiceProvider);
  final resp = await service.mangas(); 

  if (resp.code != 1) {
    throw Exception('Erreur API: ${resp.code}');
  }

  final data = resp.data;
  if (data == null) throw Exception("MangaResponse is null");

  return data.mangas; 
});

final mangaCategoriesProvider = FutureProvider<List<MangaCategory>>((
  ref,
) async {
  final service = ref.read(mangaServiceProvider);
  final resp = await service.mangas(); 

  if (resp.code != 1) {
    throw Exception('Erreur API: ${resp.code}');
  }
  final data = resp.data;
  if (data == null) {
    throw Exception("MangaResponse is null");
  }
  return data.mangas.map((m) {
    final cat = m.mangasCategory;
    return MangaCategory(
      id: cat.id,
      name: cat.name,
      description: cat.description ?? "",
    );
  }).toList();
});
