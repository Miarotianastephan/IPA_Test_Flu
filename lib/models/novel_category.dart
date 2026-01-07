enum NovelCategoryType { roman, manga, audio }

abstract class NovelCategory {
  final int id;
  final String name;
  final NovelCategoryType type;

  const NovelCategory({
    required this.id,
    required this.name,
    required this.type,
  });
}
