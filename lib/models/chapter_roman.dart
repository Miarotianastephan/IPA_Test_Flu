import 'package:live_app/models/content_roman.dart';

class RomanChapter {
  final int id;
  final int romanId;
  final int chapterNumber;
  final int wordCount;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<RomanContent> contents;
  RomanChapter({
    required this.id,
    required this.romanId,
    required this.chapterNumber,
    required this.wordCount,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
    required this.contents,
  });
  factory RomanChapter.fromJson(Map<String, dynamic> json) {
    return RomanChapter(
      id: json['id'],
      romanId: json['roman_id'],
      chapterNumber: json['chapter_number'],
      wordCount: json['word_count'],
      isPublished: json['isPublished'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      contents: (json['contents'] as List)
          .map((c) => RomanContent.fromJson(c))
          .toList(),
    );
  }
}
