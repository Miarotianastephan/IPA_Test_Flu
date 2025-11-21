import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class UniversalCacheManager {
  static final UniversalCacheManager _instance =
      UniversalCacheManager._internal();

  factory UniversalCacheManager() => _instance;

  UniversalCacheManager._internal();

  // 默认缓存管理器
  final BaseCacheManager _cacheManager = DefaultCacheManager();

  // 自定义缓存管理器
  BaseCacheManager customCacheManager({
    required String key,
    int maxObjects = 100,
    Duration stalePeriod = const Duration(days: 7),
  }) {
    return CacheManager(
      Config(key, stalePeriod: stalePeriod, maxNrOfCacheObjects: maxObjects),
    );
  }

  /// 获取文件
  Future<File?> getFile(String url, {BaseCacheManager? manager}) async {
    final cache = manager ?? _cacheManager;

    // 先检查缓存
    FileInfo? cachedFile = await cache.getFileFromCache(url);
    if (cachedFile != null) {
      return cachedFile.file;
    }

    // 没缓存就下载
    FileInfo downloadedFile = await cache.downloadFile(url);
    return downloadedFile.file;
  }

  /// 清空缓存
  Future<void> clearCache({BaseCacheManager? manager}) async {
    final cache = manager ?? _cacheManager;
    await cache.emptyCache();
  }
}
