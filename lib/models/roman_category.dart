import 'novel_category.dart';

class RomanCategory extends NovelCategory {
  RomanCategory({required super.id, required super.name})
    : super(type: NovelCategoryType.roman);

  factory RomanCategory.fromJson(Map<String, dynamic> json) {
    return RomanCategory(id: json['id'], name: json['name']);
  }
}
