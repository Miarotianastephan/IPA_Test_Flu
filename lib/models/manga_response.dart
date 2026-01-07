import 'package:live_app/models/manga.dart';

class MangaResponse {
  final bool isForce;
  final List<Manga> mangas;
  MangaResponse({required this.isForce, required this.mangas});
  factory MangaResponse.fromJson(Map<String, dynamic> json) {
    return MangaResponse(
      isForce: json['isForce'] ?? false,
      mangas: (json['mangas'] as List<dynamic>)
          .map((e) => Manga.fromJson(e))
          .toList(),
    );
  }
}
