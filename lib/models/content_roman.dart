import 'package:live_app/models/roman_language.dart';

class RomanContent {
  final int id;
  final int chapterId;
  final String i18Language;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final RomanLanguage language;
  RomanContent({
    required this.id,
    required this.chapterId,
    required this.i18Language,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.language,
  });
  factory RomanContent.fromJson(Map<String, dynamic> json) {
    return RomanContent(
      id: json['id'],
      chapterId: json['chapter_id'],
      i18Language: json['i18_language'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      language: RomanLanguage.fromJson(json['language']),
    );
  }
}
