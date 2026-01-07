class RomanLanguage {
  final String code;
  final String name;
  RomanLanguage({required this.code, required this.name});
  factory RomanLanguage.fromJson(Map<String, dynamic> json) {
    return RomanLanguage(code: json['code'], name: json['name']);
  }
}
