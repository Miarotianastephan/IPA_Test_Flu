
import 'package:live_app/models/episode_manga.dart';
import 'package:live_app/models/titles_manga.dart';

class ChapterManga {
  final int id;
  final String title;
  final int chapterNumber;
  final String description;
  final List<TitlesManga> titles;
  final List<EpisodeManga> episodes;
  ChapterManga({
    required this.id,
    required this.title,
    required this.chapterNumber,
    required this.description,
    required this.titles,
    required this.episodes,
  });
  factory ChapterManga.fromJson(Map<String, dynamic> json) {
    return ChapterManga(
      id: json['id'],
      title: json['title'] ?? '',
      chapterNumber: json['chapter_number'],
      description: json['description'] ?? '',
      titles: (json['titles'] as List<dynamic>)
          .map((e) => TitlesManga.fromJson(e))
          .toList(),
      episodes: (json['episodes'] as List<dynamic>)
          .map((e) => EpisodeManga.fromJson(e))
          .toList(),
    );
  }
}
