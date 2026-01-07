class RomanCreator {
  final int id;
  final String name;
  final String avatar;
  final String gender;
  RomanCreator({
    required this.id,
    required this.name,
    required this.avatar,
    required this.gender,
  });
  factory RomanCreator.fromJson(Map<String, dynamic> json) {
    return RomanCreator(
      id: json['id'],
      name: json['name'],
      avatar: json['avatar'],
      gender: json['gender'],
    );
  }
}
