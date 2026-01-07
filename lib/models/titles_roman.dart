import 'package:live_app/models/roman_language.dart';

class RomanTitle {
  final int id;
  final String title;
  final String description;
  final int romanId;
  final String i18Language;
  final RomanLanguage language;
  RomanTitle({
    required this.id,
    required this.title,
    required this.description,
    required this.romanId,
    required this.i18Language,
    required this.language,
  });
  factory RomanTitle.fromJson(Map<String, dynamic> json) {
    return RomanTitle(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      romanId: json['roman_id'],
      i18Language: json['i18_language'],
      language: RomanLanguage.fromJson(json['language']),
    );
  }
}
