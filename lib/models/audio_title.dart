import 'package:live_app/models/language_audio.dart';

class AudioTitle {
  final int id;
  final String title;
  final String description;
  final String i18Language;
  final DateTime createdAt;
  final DateTime updatedAt;
  final LanguageAudio language;

  AudioTitle({
    required this.id,
    required this.title,
    required this.description,
    required this.i18Language,
    required this.createdAt,
    required this.updatedAt,
    required this.language,
  });

  factory AudioTitle.fromJson(Map<String, dynamic> json) {
    return AudioTitle(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      i18Language: json['i18_language'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      language: LanguageAudio.fromJson(json['language']),
    );
  }
}
