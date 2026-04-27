class AlbumAudioTitle {
  final String title;
  final String description;
  final String i18Language;
  final String languageCode;

  AlbumAudioTitle({
    required this.title,
    required this.description,
    required this.i18Language,
    required this.languageCode,
  });

  factory AlbumAudioTitle.fromJson(Map<String, dynamic> json) {
    return AlbumAudioTitle(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      i18Language: json['i18_language'] ?? '',
      languageCode: json['language_code'] ?? '',
    );
  }
}
