class LanguageAudio {
  final String code;
  final String name;

  LanguageAudio({required this.code, required this.name});

  factory LanguageAudio.fromJson(Map<String, dynamic> json) {
    return LanguageAudio(code: json['code'] ?? '', name: json['name'] ?? '');
  }
}
