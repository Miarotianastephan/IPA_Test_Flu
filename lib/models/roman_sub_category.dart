class RomanSubCategory {
  final int id;
  final String name;
  RomanSubCategory({required this.id, required this.name});
  factory RomanSubCategory.fromJson(Map<String, dynamic> json) {
    return RomanSubCategory(id: json['id'], name: json['name']);
  }
}
