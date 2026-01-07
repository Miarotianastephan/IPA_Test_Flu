class TitlesManga {
  final int id;
  final String title;
  final String description;
  final String languageCode;
  TitlesManga({
    required this.id,
    required this.title,
    required this.description,
    required this.languageCode,
  });
  factory TitlesManga.fromJson(Map<String, dynamic> json) {
    return TitlesManga(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      languageCode: json['i18_language'] ?? '',
    );
  }
}
