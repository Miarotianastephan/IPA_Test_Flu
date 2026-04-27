class AudioSubCategory {
  final int id;
  final String name;

  AudioSubCategory({required this.id, required this.name});

  factory AudioSubCategory.fromJson(Map<String, dynamic> json) {
    return AudioSubCategory(id: json['id'], name: json['name'] ?? '');
  }
}
