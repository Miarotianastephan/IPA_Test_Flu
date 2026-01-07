import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../api/api_client.dart';
import '../database/dao/image_dao.dart';
import '../models/image_cache.dart';
import '../provider/api_provider.dart';
import 'image_web_cache_stub.dart'
    if (dart.library.js_interop) 'image_web_cache.dart';

class ImageRepository {
  final ImageDao _imageDao;
  final ApiClient _apiClient;
  final ImageWebCache _webCache = ImageWebCache();

  Future<void> _downloadQueue = Future.value();

  ImageRepository({required ImageDao imageDao, required ApiClient apiClient})
    : _imageDao = imageDao,
      _apiClient = apiClient;

  Future<void> enqueueDownload(String url) async {
    _downloadQueue = _downloadQueue.then((_) async {
      try {
        await downloadAndCacheImage(url);
      } catch (e) {
        debugPrint('[ImageRepository] Queue error for $url: $e');
      }
    });
    return _downloadQueue;
  }

  Future<ImageCache?> getImageCache(String url) async {
    try {
      return await _imageDao.getImageByUrl(url);
    } catch (e) {
      debugPrint('[ImageRepository] Error getting image cache: $e');
      return null;
    }
  }

  Future<ImageCache?> downloadAndCacheImage(String url) async {
    try {
      if (kIsWeb) {
        try {
          dynamic downloaded = await _apiClient.downloadFile(url, save: false);
          if (downloaded is Uint8List) {
            Uint8List bytes = downloaded;
            if (url.toLowerCase().endsWith('.pdf')) {
              bytes = await _decrypt(bytes);
            }
            final base64String = base64Encode(bytes);
            await _webCache.put(url, base64String);
            return ImageCache(url: url, localPath: 'web_cache');
          }
        } catch (e) {
          return null;
        }
      } else {
        final existing = await getImageCache(url);
        if (existing != null && existing.localPath != null) {
          if (await io.File(existing.localPath!).exists()) {
            return existing;
          }
        }
      }

      if (kIsWeb) {
        try {
          dynamic downloaded = await _apiClient.downloadFile(url, save: false);
          if (downloaded is Uint8List) {
            Uint8List bytes = downloaded;
            if (url.toLowerCase().endsWith('.pdf')) {
              bytes = await _decrypt(bytes);
            }
            final base64String = base64Encode(bytes);
            await _webCache.put(url, base64String);
            return ImageCache(url: url, localPath: 'web_cache');
          }
        } catch (e) {
          debugPrint('[ImageRepository] Web cache unavailable for $url: $e');
          return null;
        }
      }

      final localPath = await _getCacheFilePath(url);
      if (localPath == null) return null;

      final downloaded = await _apiClient.downloadFile(
        url,
        save: true,
        savePath: localPath,
      );

      if (downloaded is! io.File) {
        throw Exception(
          'Expected File result from downloadFile with save: true, got ${downloaded.runtimeType}',
        );
      }

      if (url.toLowerCase().endsWith('.pdf')) {
        final bytes = await downloaded.readAsBytes();
        final decryptedBytes = await _decrypt(bytes);
        await downloaded.writeAsBytes(decryptedBytes);
      }

      final imageCache = ImageCache(url: url, localPath: localPath);
      await _imageDao.upsertImage(imageCache);

      return imageCache;
    } catch (e) {
      debugPrint('[ImageRepository] Error downloading image: $e');
      return null;
    }
  }

  Future<Uint8List?> getImageBytes(String url) async {
    try {
      if (kIsWeb) {
        final cachedBase64 = await _webCache.get(url);
        if (cachedBase64 != null) {
          return base64Decode(cachedBase64);
        }
        return null;
      }

      final cache = await getImageCache(url);

      if (cache?.localPath != null) {
        final file = io.File(cache!.localPath!);
        if (await file.exists()) {
          return await file.readAsBytes();
        }
      }
      return null;
    } catch (e) {
      debugPrint('[ImageRepository] Error getting image bytes: $e');
      return null;
    }
  }

  Future<String?> _getCacheFilePath(String url) async {
    try {
      if (kIsWeb) return null;

      final directory = await getApplicationDocumentsDirectory();
      final cacheDir = io.Directory(path.join(directory.path, 'image_cache'));

      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }

      final filename = _generateFilename(url);
      return path.join(cacheDir.path, filename);
    } catch (e) {
      debugPrint('[ImageRepository] Error getting cache file path: $e');
      return null;
    }
  }

  String _generateFilename(String url) {
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;

    if (pathSegments.isNotEmpty) {
      return pathSegments.last;
    }

    return '${url.hashCode.abs()}.jpg';
  }

  Future<Uint8List> _decrypt(Uint8List data) async {
    final decrypted = data.map((b) => b ^ 0xFF).toList();
    return Uint8List.fromList(decrypted);
  }

  Future<void> clearCache() async {
    try {
      if (kIsWeb) {
        await _webCache.clear();
      }

      final images = await _imageDao.getDownloadedImages();
      await _imageDao.deleteAllImages();

      if (!kIsWeb) {
        for (final image in images) {
          if (image.localPath != null) {
            final file = io.File(image.localPath!);
            if (await file.exists()) {
              await file.delete();
            }
          }
        }
      }
    } catch (e) {
      debugPrint('[ImageRepository] Error clearing cache: $e');
    }
  }

  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      if (kIsWeb) {
        final count = await _webCache.getCount();
        return {
          'count': count,
          'totalSize': 0, // Hard to calculate exactly on web
          'formattedSize': ' ',
        };
      }

      final count = await _imageDao.getImageCount();
      int totalSize = 0;

      final images = await _imageDao.getDownloadedImages();
      for (final image in images) {
        if (image.localPath != null) {
          final file = io.File(image.localPath!);
          if (await file.exists()) {
            totalSize += await file.length();
          }
        }
      }

      return {
        'count': count,
        'totalSize': totalSize,
        'formattedSize': _formatBytes(totalSize),
      };
    } catch (e) {
      debugPrint('[ImageRepository] Error getting cache stats: $e');
      return {'count': 0, 'totalSize': 0, 'formattedSize': '0 B'};
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

final imageRepositoryProvider = Provider<ImageRepository>((ref) {
  final imageDao = ref.watch(imageDaoProvider);
  final apiClient = ref.watch(apiClientProvider);

  return ImageRepository(imageDao: imageDao, apiClient: apiClient);
});
