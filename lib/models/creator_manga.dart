class Creator {
  final int id;
  final String name;
  final String? avatar;
  Creator({required this.id, required this.name, this.avatar});
  factory Creator.fromJson(Map<String, dynamic> json) {
    return Creator(
      id: json['id'],
      name: json['name'] ?? '',
      avatar: json['avatar'],
    );
  }
}
