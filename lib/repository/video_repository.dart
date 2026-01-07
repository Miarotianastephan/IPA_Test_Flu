import 'dart:convert';
import 'dart:io' as io;
import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/api/api_client.dart';
import 'package:live_app/database/dao/video_dao.dart';
import 'package:live_app/models/video_cache.dart';
import 'package:live_app/provider/api_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'video_web_cache.dart'
    if (dart.library.js_interop) 'video_web_cache.dart'
    if (dart.library.io) 'video_web_cache_stub.dart';

class VideoRepository {
  final VideoDao _videoDao;
  final ApiClient _apiClient;
  final VideoWebCache _webCache = VideoWebCache();

  final Set<String> _activeDownloads = {};
  Future<void> _downloadQueue = Future.value();

  VideoRepository({required VideoDao videoDao, required ApiClient apiClient})
    : _videoDao = videoDao,
      _apiClient = apiClient;

  Future<void> enqueueDownload(String url) async {
    if (!_isCacheable(url)) return;

    if (_activeDownloads.contains(url)) return;

    _downloadQueue = _downloadQueue.then((_) async {
      if (_activeDownloads.contains(url)) return;

      try {
        _activeDownloads.add(url);
        await downloadAndCacheVideo(url);
      } catch (e) {
        debugPrint('[VideoRepository] Queue error for $url: $e');
      } finally {
        _activeDownloads.remove(url);
      }
    });
    return _downloadQueue;
  }

  bool _isCacheable(String url) {
    final lowUrl = url.toLowerCase();
    return !lowUrl.contains('.m3u8') && !lowUrl.contains('.mpd');
  }

  Future<VideoCache?> downloadAndCacheVideo(String url) async {
    if (!_isCacheable(url)) return null;

    try {
      if (kIsWeb) {
        try {
          dynamic downloaded = await _apiClient.downloadFile(url, save: false);
          if (downloaded is Uint8List) {
            final base64String = base64Encode(downloaded);
            await _webCache.put(url, base64String);
            return VideoCache(url: url, localPath: 'web_cache');
          }
        } catch (e) {
          return null;
        }
      } else {
        final localPath = await _getCacheFilePath(url);
        if (localPath == null) return null;

        final file = io.File(localPath);
        if (await file.exists()) {
          return VideoCache(url: url, localPath: localPath);
        }

        final downloaded = await _apiClient.downloadFile(url, save: true);

        if (downloaded is! io.File) {
          throw Exception(
            'Expected File result from downloadFile with save: true, got ${downloaded.runtimeType}',
          );
        }

        if (downloaded.path != localPath) {
          await downloaded.copy(localPath);
          await downloaded.delete();
        }

        final videoCache = VideoCache(url: url, localPath: localPath);
        await _videoDao.upsertVideo(videoCache);

        return videoCache;
      }
      return null;
    } catch (e) {
      debugPrint('[VideoRepository] Error downloading video: $e');
      return null;
    }
  }

  Future<String?> getVideoPath(String url) async {
    if (!_isCacheable(url)) return null;

    try {
      if (kIsWeb) {
        final cachedBase64 = await _webCache.get(url);
        if (cachedBase64 != null) {
          return 'data:video/mp4;base64,$cachedBase64';
        }
        return null;
      }

      final cache = await getVideoCache(url);

      if (cache?.localPath != null) {
        final file = io.File(cache!.localPath!);
        if (await file.exists()) {
          return cache.localPath;
        }
      }
      return null;
    } catch (e) {
      debugPrint('[VideoRepository] Error getting video path: $e');
      return null;
    }
  }

  Future<VideoCache?> getVideoCache(String url) async {
    try {
      return await _videoDao.getVideoByUrl(url);
    } catch (e) {
      debugPrint('[VideoRepository] Error getting video cache: $e');
      return null;
    }
  }

  Future<String?> _getCacheFilePath(String url) async {
    try {
      if (kIsWeb) return null;

      final directory = await getApplicationDocumentsDirectory();
      final cacheDir = io.Directory(path.join(directory.path, 'video_cache'));

      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }

      final filename = _generateFilename(url);
      return path.join(cacheDir.path, filename);
    } catch (e) {
      debugPrint('[VideoRepository] Error getting cache file path: $e');
      return null;
    }
  }

  String _generateFilename(String url) {
    final hash = crypto.md5.convert(utf8.encode(url)).toString();
    final uri = Uri.parse(url);
    final ext = path.extension(uri.path);
    return ext.isEmpty ? '$hash.mp4' : '$hash$ext';
  }

  Future<void> clearCache() async {
    try {
      if (kIsWeb) {
        await _webCache.clear();
      }

      final videos = await _videoDao.getDownloadedVideos();
      await _videoDao.deleteAllVideos();

      if (!kIsWeb) {
        for (final video in videos) {
          if (video.localPath != null) {
            final file = io.File(video.localPath!);
            if (await file.exists()) {
              await file.delete();
            }
          }
        }
      }
    } catch (e) {
      debugPrint('[VideoRepository] Error clearing cache: $e');
    }
  }
}

final videoRepositoryProvider = Provider<VideoRepository>((ref) {
  final videoDao = ref.watch(videoDaoProvider);
  final apiClient = ref.watch(apiClientProvider);

  return VideoRepository(videoDao: videoDao, apiClient: apiClient);
});
