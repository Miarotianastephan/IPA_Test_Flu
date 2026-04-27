class AudioCreator {
  final int id;
  final String name;
  final String? avatar;

  AudioCreator({required this.id, required this.name, this.avatar});

  factory AudioCreator.fromJson(Map<String, dynamic> json) {
    return AudioCreator(
      id: json['id'],
      name: json['name'] ?? '',
      avatar: json['avatar'],
    );
  }
}
