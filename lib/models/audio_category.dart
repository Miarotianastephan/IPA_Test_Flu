import 'novel_category.dart';

class AudioCategory extends NovelCategory {
  final String? description;

  AudioCategory({required super.id, required super.name, this.description})
    : super(type: NovelCategoryType.audio);

  factory AudioCategory.fromJson(Map<String, dynamic> json) {
    return AudioCategory(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
    );
  }
}
