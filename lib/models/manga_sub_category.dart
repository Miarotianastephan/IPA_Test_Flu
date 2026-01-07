class MangaSubCategory {
  final int id;
  final String name;
  MangaSubCategory({required this.id, required this.name});
  factory MangaSubCategory.fromJson(Map<String, dynamic> json) {
    return MangaSubCategory(id: json['id'], name: json['name'] ?? '');
  }
}
