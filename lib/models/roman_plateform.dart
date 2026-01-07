class RomanPlateform {
  final int id;
  final String name;
  final String videoSyncUrl;
  final String postSyncUrl;
  RomanPlateform({
    required this.id,
    required this.name,
    required this.videoSyncUrl,
    required this.postSyncUrl,
  });
  factory RomanPlateform.fromJson(Map<String, dynamic> json) {
    return RomanPlateform(
      id: json['id'],
      name: json['name'],
      videoSyncUrl: json['video_sync_url'],
      postSyncUrl: json['post_sync_url'],
    );
  }
}
