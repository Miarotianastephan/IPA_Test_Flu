import 'dart:async';
import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pool/pool.dart';

import '../api/api_client.dart';
import '../database/dao/image_dao.dart';
import '../models/cache_stats.dart';
import '../models/image_cache.dart';
import '../provider/api_provider.dart';
import '../services/web_image_worker_client_stub.dart'
    if (dart.library.html) '../services/web_image_worker_client_web.dart'
    as web_image_worker;
import '../utils/decrypt_utils.dart';
import '../utils/text_util.dart';
import 'image_layout_utils.dart';
import 'image_repository_background.dart';
import 'image_web_cache_stub.dart'
    if (dart.library.js_interop) 'image_web_cache.dart';

export 'image_layout_utils.dart' show ImageLayoutInfo;

class ImageRepository {
  static const int _maxMemoryCacheEntries = 300;
  static const int _maxLayoutCacheEntries = 240;

  final ImageDao _imageDao;
  final ApiClient _apiClient;
  final ImageWebCache _webCache = ImageWebCache();
  static final _encImgKey = dotenv.env['ENCRYPTION_KEY'] ?? "";
  final Pool _pool = Pool(kIsWeb ? 12 : 4);
  final Pool _bytesLoadPool = Pool(kIsWeb ? 12 : 2);
  final Set<String> _inProgress = {};
  final Map<String, Uint8List> _memoryBytesCache = {};
  final Map<String, ImageLayoutInfo> _memoryLayoutCache = {};
  final Map<String, Future<Uint8List>> _bytesLoadFutures = {};
  final Map<String, Future<ImageLayoutInfo>> _layoutLoadFutures = {};

  ImageRepository({required ImageDao imageDao, required ApiClient apiClient})
    : _imageDao = imageDao,
      _apiClient = apiClient;

  void enqueueDownload(String url) {
    if (_inProgress.contains(url)) return;
    _inProgress.add(url);

    _pool.withResource(() async {
      try {
        await downloadAndCacheImage(url, false);
      } catch (e) {
        debugPrint('[ImageRepository] Download error $url: $e');
      } finally {
        _inProgress.remove(url);
      }
    });
  }

  void enqueueWarmBytes(String url) {
    if (_inProgress.contains(url) || _memoryBytesCache.containsKey(url)) return;
    _inProgress.add(url);

    _pool.withResource(() async {
      try {
        await getImageBytes(url);
      } catch (e) {
        debugPrint('[ImageRepository] Warm bytes error $url: $e');
      } finally {
        _inProgress.remove(url);
      }
    });
  }

  Future<ImageCache> _downloadAndCacheImageOnWeb(
    ImageCache imageCache,
    bool isReturnBytes,
  ) async {
    if (isReturnBytes) {
      final memoryBytes = _getMemoryCachedBytes(imageCache.url);
      if (memoryBytes != null) {
        imageCache.bytes = memoryBytes;
        return imageCache;
      }
    }

    //先从缓存取 没有再下载
    Uint8List? cachedBytes = await _webCache.get(imageCache.url);
    if (cachedBytes != null) {
      Uint8List bytes = cachedBytes;
      imageCache.bytes = bytes;
      _cacheBytesInMemory(imageCache.url, bytes);
    } else {
      dynamic downloaded = await _apiClient.downloadFile(
        imageCache.url,
        save: false,
      );

      if (downloaded is! Uint8List) {
        // 如果下载结果不是 Uint8List，直接抛出异常
        throw StateError(
          'Download failed or returned unsupported type: ${downloaded.runtimeType}',
        );
      }

      if (isReturnBytes) {
        // 需要解密才处理 bytes
        Uint8List bytes = await _checkSuffixAndDecrypt(
          imageCache.url,
          downloaded,
        );
        await _webCache.put(imageCache.url, bytes);
        imageCache.bytes = bytes;
        _cacheBytesInMemory(imageCache.url, bytes);
      }
    }
    return imageCache;
  }

  Future<ImageCache> _downloadAndCacheImageOnDevice(
    ImageCache imageCache,
    bool isReturnBytes,
  ) async {
    if (isReturnBytes) {
      final memoryBytes = _getMemoryCachedBytes(imageCache.url);
      if (memoryBytes != null) {
        imageCache.bytes = memoryBytes;
        return imageCache;
      }
    }

    // 检查本地缓存
    final existing = await getImageCache(imageCache.url);
    if (existing?.localPath != null &&
        await io.File(existing!.localPath!).exists()) {
      return isReturnBytes ? await _loadBytesToCache(existing) : existing;
    }

    // 获取本地路径
    final localPath =
        await _getCacheFilePath(imageCache.url) ??
        (throw StateError(
          'Failed to get local cache path for ${imageCache.url}',
        ));

    // 下载文件
    final downloaded = await _apiClient.downloadFile(
      imageCache.url,
      save: true,
      savePath: localPath,
    );

    if (downloaded is! io.File) {
      throw Exception(
        'Expected File result from downloadFile with save: true, got ${downloaded.runtimeType}',
      );
    }

    // 读取并解密 bytes
    if (isReturnBytes) {
      // 读取并解密 bytes
      final finalBytes = await _readAndDecryptFile(
        downloaded.path,
        imageCache.url,
      );
      imageCache.bytes = finalBytes;
      _cacheBytesInMemory(imageCache.url, finalBytes);
    }

    imageCache.localPath = localPath;

    // 保存到数据库
    await _imageDao.upsertImage(imageCache);

    return imageCache;
  }

  //从文件加载 bytes
  Future<ImageCache> _loadBytesToCache(ImageCache cached) async {
    cached.bytes = await _readAndDecryptFile(cached.localPath!, cached.url);
    _cacheBytesInMemory(cached.url, cached.bytes!);
    return cached;
  }

  //读取 + 解密文件
  Future<Uint8List> _readAndDecryptFile(String filePath, String url) async {
    return compute(
      readAndDecryptFileInBackground,
      ReadAndDecryptParams(
        filePath: filePath,
        url: url,
        encryptionKey: _encImgKey,
      ),
    );
  }

  Future<ImageCache> downloadAndCacheImage(
    String url, [
    bool isReturnBytes = true,
  ]) async {
    final imageCache = ImageCache(url: url);
    if (kIsWeb) {
      return _downloadAndCacheImageOnWeb(imageCache, isReturnBytes);
    }
    return _downloadAndCacheImageOnDevice(imageCache, isReturnBytes);
  }

  Uint8List? getMemoryCachedBytes(String url) => _getMemoryCachedBytes(url);

  void cacheImageBytes(String url, Uint8List bytes) {
    _cacheBytesInMemory(url, bytes);
  }

  ImageLayoutInfo? getCachedImageLayout(String url) =>
      _getMemoryCachedLayout(url);

  void enqueueWarmLayout(String url) {
    if (url.isEmpty ||
        !isValidUrl(url) ||
        _memoryLayoutCache.containsKey(url) ||
        _layoutLoadFutures.containsKey(url)) {
      return;
    }

    unawaited(() async {
      try {
        await getImageLayout(url);
      } catch (error) {
        debugPrint('[ImageRepository] Warm layout error $url: $error');
      }
    }());
  }

  Future<ImageLayoutInfo> getImageLayout(String url) {
    final cachedLayout = _getMemoryCachedLayout(url);
    if (cachedLayout != null) {
      return Future.value(cachedLayout);
    }

    final existingFuture = _layoutLoadFutures[url];
    if (existingFuture != null) {
      return existingFuture;
    }

    final future = _loadImageLayout(url);
    _layoutLoadFutures[url] = future;

    return future.whenComplete(() {
      _layoutLoadFutures.remove(url);
    });
  }

  Future<Uint8List?> getCachedImageBytesIfAvailable(String url) async {
    final memoryBytes = _getMemoryCachedBytes(url);
    if (memoryBytes != null) {
      return memoryBytes;
    }

    if (kIsWeb) {
      final cachedBytes = await _webCache.get(url);
      if (cachedBytes == null) {
        return null;
      }
      _cacheBytesInMemory(url, cachedBytes);
      return cachedBytes;
    }

    final existing = await getImageCache(url);
    if (existing?.localPath == null) {
      return null;
    }

    final file = io.File(existing!.localPath!);
    if (!await file.exists()) {
      return null;
    }

    final loaded = await _loadBytesToCache(existing);
    return loaded.bytes;
  }

  Future<void> persistRawImageBytes(String url, Uint8List rawBytes) async {
    try {
      if (kIsWeb) {
        return;
      }

      final localPath = await _getCacheFilePath(url);
      if (localPath == null) {
        return;
      }

      final file = io.File(localPath);
      await file.writeAsBytes(rawBytes, flush: false);
      await _imageDao.upsertImage(ImageCache(url: url, localPath: localPath));
    } catch (e) {
      debugPrint('[ImageRepository] Persist raw image error $url: $e');
    }
  }

  Future<Uint8List> getImageBytes(String url) {
    final memoryBytes = _getMemoryCachedBytes(url);
    if (memoryBytes != null) {
      return Future.value(memoryBytes);
    }

    final existingFuture = _bytesLoadFutures[url];
    if (existingFuture != null) {
      return existingFuture;
    }

    Future<Uint8List> loader() async {
      final imageCache = await downloadAndCacheImage(url);
      final bytes = imageCache.bytes;
      if (bytes == null) {
        throw StateError('Image bytes is null for url: $url');
      }
      return bytes;
    }

    final future = kIsWeb ? loader() : _bytesLoadPool.withResource(loader);

    _bytesLoadFutures[url] = future;

    return future.whenComplete(() {
      _bytesLoadFutures.remove(url);
    });
  }

  Uint8List? _getMemoryCachedBytes(String url) {
    final bytes = _memoryBytesCache.remove(url);
    if (bytes == null) return null;
    _memoryBytesCache[url] = bytes;
    return bytes;
  }

  void _cacheBytesInMemory(String url, Uint8List bytes) {
    _memoryBytesCache.remove(url);
    _memoryBytesCache[url] = bytes;

    if (_memoryBytesCache.length <= _maxMemoryCacheEntries) {
      return;
    }

    final oldestKey = _memoryBytesCache.keys.first;
    _memoryBytesCache.remove(oldestKey);
  }

  ImageLayoutInfo? _getMemoryCachedLayout(String url) {
    final layout = _memoryLayoutCache.remove(url);
    if (layout == null) return null;
    _memoryLayoutCache[url] = layout;
    return layout;
  }

  void _cacheLayoutInMemory(String url, ImageLayoutInfo layout) {
    _memoryLayoutCache.remove(url);
    _memoryLayoutCache[url] = layout;

    if (_memoryLayoutCache.length <= _maxLayoutCacheEntries) {
      return;
    }

    final oldestKey = _memoryLayoutCache.keys.first;
    _memoryLayoutCache.remove(oldestKey);
  }

  Future<ImageLayoutInfo> _loadImageLayout(String url) async {
    final webLayout = await _tryLoadWebImageLayout(url);
    if (webLayout != null) {
      _cacheLayoutInMemory(url, webLayout);
      return webLayout;
    }

    final cachedBytes = await getCachedImageBytesIfAvailable(url);
    final bytes = cachedBytes ?? await getImageBytes(url);
    final layout = await compute(
      readImageLayoutInBackground,
      ReadImageLayoutParams(bytes: bytes, url: url),
    );
    _cacheLayoutInMemory(url, layout);
    return layout;
  }

  Future<ImageLayoutInfo?> _tryLoadWebImageLayout(String url) async {
    if (!kIsWeb || !web_image_worker.supportsWebImageWorker) {
      return null;
    }

    final fileType = webWorkerFileType(url);
    if (fileType == null) {
      return null;
    }

    final encryptionKey = dotenv.env['ENCRYPTION_KEY'] ?? '';
    if (encryptionKey.isEmpty) {
      return null;
    }

    try {
      final cached = web_image_worker.getCachedWebImageLayout(
        url: url,
        encryptionKey: encryptionKey,
      );
      if (cached != null) {
        return ImageLayoutInfo(
          isSvg: cached.isSvg,
          aspectRatio: cached.aspectRatio,
        );
      }

      final loaded = await web_image_worker.warmWebImageLayout(
        url: url,
        fileType: fileType,
        encryptionKey: encryptionKey,
      );
      if (loaded == null) {
        return null;
      }

      return ImageLayoutInfo(
        isSvg: loaded.isSvg,
        aspectRatio: loaded.aspectRatio,
      );
    } catch (error) {
      debugPrint('[ImageRepository] Web worker layout fallback $url: $error');
      return null;
    }
  }

  Future<ImageCache?> getImageCache(String url) async {
    try {
      return await _imageDao.getImageByUrl(url);
    } catch (e) {
      debugPrint('[ImageRepository] Error getting image cache: $e');
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

  Future<void> clearCache() async {
    try {
      _memoryBytesCache.clear();
      _memoryLayoutCache.clear();
      _bytesLoadFutures.clear();
      _layoutLoadFutures.clear();
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

  Future<CacheStats> getCacheStats() async {
    try {
      if (kIsWeb) {
        final count = await _webCache.getCount();
        return CacheStats(count: count, totalSize: 0, formattedSize: '0 B');
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

      return CacheStats(
        count: count,
        totalSize: totalSize,
        formattedSize: formatBytes(totalSize),
      );
    } catch (e) {
      debugPrint('[ImageRepository] Error getting cache stats: $e');
      return CacheStats.empty();
    }
  }

  Future<Uint8List> _checkSuffixAndDecrypt(
    String url,
    Uint8List rawBytes,
  ) async {
    final fileType = getImageFileType(url);

    if (fileType == null) {
      throw UnsupportedError(
        'Unsupported file type: $url. Only .pdf and .enc are allowed.',
      );
    }

    // .pdf cover URLs carry the same encrypted image payload as .enc files.
    switch (fileType) {
      case ImageFileType.enc:
        return await _decryptEncImage(rawBytes);
      case ImageFileType.pdf:
        return await _decryptEncImage(rawBytes);
    }
  }

  Future<Uint8List> _decryptEncImage(Uint8List rawBytes) async {
    final decryptUtils = DecryptUtils(_encImgKey);
    final decryptedBytes = await decryptUtils.decryptBufferAsync(rawBytes);
    return decryptedBytes;
  }
}

final imageRepositoryProvider = Provider<ImageRepository>((ref) {
  final imageDao = ref.watch(imageDaoProvider);
  final apiClient = ref.watch(apiClientProvider);

  return ImageRepository(imageDao: imageDao, apiClient: apiClient);
});
