class ImageCache {
  final String url;
  final String? localPath;

  const ImageCache({required this.url, this.localPath});

  bool get isDownloaded => localPath != null;

  ImageCache copyWith({String? url, String? localPath}) {
    return ImageCache(
      url: url ?? this.url,
      localPath: localPath ?? this.localPath,
    );
  }
}
