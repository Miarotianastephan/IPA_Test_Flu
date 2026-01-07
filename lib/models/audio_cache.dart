class AudioCache {
  final String url;
  final String? localPath;

  const AudioCache({required this.url, this.localPath});

  bool get isDownloaded => localPath != null;

  AudioCache copyWith({String? url, String? localPath}) {
    return AudioCache(
      url: url ?? this.url,
      localPath: localPath ?? this.localPath,
    );
  }
}
