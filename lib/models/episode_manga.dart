import 'package:live_app/models/manga_image.dart';

class EpisodeManga {
  final int id;
  final int number;
  final String name;
  final String description;
  final List<String> images;
  final List<MangaImage> mangasImages;
  EpisodeManga({
    required this.id,
    required this.number,
    required this.name,
    required this.description,
    required this.images,
    required this.mangasImages,
  });
  factory EpisodeManga.fromJson(Map<String, dynamic> json) {
    return EpisodeManga(
      id: json['id'],
      number: json['number'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      mangasImages: (json['mangasImages'] as List<dynamic>)
          .map((e) => MangaImage.fromJson(e))
          .toList(),
    );
  }
}
