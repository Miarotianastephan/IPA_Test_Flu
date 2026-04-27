import 'dart:typed_data';

class ImageCache {
  final String url;
  String? localPath;
  Uint8List? bytes;

  ImageCache({
    required this.url,
    this.localPath,
    this.bytes,
  });

  bool get isDownloaded => localPath != null;
}