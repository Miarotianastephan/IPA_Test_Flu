import 'novel_category.dart';

class MangaCategory extends NovelCategory {
  final String? description;

  MangaCategory({
    required super.id,
    required super.name,
    required this.description,
  }) : super(type: NovelCategoryType.manga);

  factory MangaCategory.fromJson(Map<String, dynamic> json) {
    return MangaCategory(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
