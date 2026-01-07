class MangaImage {
  final int id;
  final String imageId;
  final String s3ImageUrl;
  MangaImage({
    required this.id,
    required this.imageId,
    required this.s3ImageUrl,
  });
  factory MangaImage.fromJson(Map<String, dynamic> json) {
    return MangaImage(
      id: json['id'],
      imageId: json['image_id'] ?? '',
      s3ImageUrl: json['s3_image_url'] ?? '',
    );
  }
}
