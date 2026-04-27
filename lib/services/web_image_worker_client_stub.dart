import 'web_image_worker_models.dart';

const bool supportsWebImageWorker = false;

WebImageLayoutData? getCachedWebImageLayout({
  required String url,
  required String encryptionKey,
}) => null;

WebImageDisplayData? getCachedWebImageDisplay({
  required String url,
  required String encryptionKey,
  int? targetWidth,
}) => null;

Future<WebImageLayoutData?> warmWebImageLayout({
  required String url,
  required String fileType,
  required String encryptionKey,
}) async => null;

Future<WebImageDisplayData?> loadWebImage({
  required String url,
  required String fileType,
  required String encryptionKey,
  int? targetWidth,
}) async => null;
