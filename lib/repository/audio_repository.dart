import 'dart:async';
import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../api/api_client.dart';
import '../database/dao/audio_dao.dart';
import '../models/audio_cache.dart';
import '../provider/api_provider.dart';

class AudioRepository {
  final AudioDao _audioDao;
  final ApiClient _apiClient;

  Future<void> _downloadQueue = Future.value();

  AudioRepository({required AudioDao audioDao, required ApiClient apiClient})
    : _audioDao = audioDao,
      _apiClient = apiClient;

  Future<void> enqueueDownload(String url) async {
    _downloadQueue = _downloadQueue.then((_) async {
      try {
        await downloadAndCacheAudio(url);
      } catch (e) {
        debugPrint('[AudioRepository] Queue error for $url: $e');
      }
    });
    return _downloadQueue;
  }

  Future<AudioCache?> getAudioCache(String url) async {
    try {
      return await _audioDao.getAudioByUrl(url);
    } catch (e) {
      debugPrint('[AudioRepository] Error getting audio cache: $e');
      return null;
    }
  }

  Future<AudioCache?> downloadAndCacheAudio(String url) async {
    try {
      final existing = await getAudioCache(url);
      if (existing != null && existing.localPath != null) {
        if (await io.File(existing.localPath!).exists()) {
          return existing;
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

      final audioCache = AudioCache(url: url, localPath: localPath);
      await _audioDao.upsertAudio(audioCache);

      return audioCache;
    } catch (e) {
      debugPrint('[AudioRepository] Error downloading audio: $e');
      return null;
    }
  }

  Future<String?> getAudioPath(String url) async {
    try {
      final cache = await getAudioCache(url);

      if (cache?.localPath != null) {
        final file = io.File(cache!.localPath!);
        if (await file.exists()) {
          return cache.localPath;
        }
      }
      return null;
    } catch (e) {
      debugPrint('[AudioRepository] Error getting audio path: $e');
      return null;
    }
  }

  Future<String?> _getCacheFilePath(String url) async {
    try {
      if (kIsWeb) return null;

      final directory = await getApplicationDocumentsDirectory();
      final cacheDir = io.Directory(path.join(directory.path, 'audio_cache'));

      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }

      final filename = _generateFilename(url);
      return path.join(cacheDir.path, filename);
    } catch (e) {
      debugPrint('[AudioRepository] Error getting cache file path: $e');
      return null;
    }
  }

  String _generateFilename(String url) {
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;

    if (pathSegments.isNotEmpty) {
      return pathSegments.last;
    }

    return '${url.hashCode.abs()}.mp3';
  }

  Future<void> clearCache() async {
    try {
      final audios = await _audioDao.getDownloadedAudios();
      await _audioDao.deleteAllAudios();

      for (final audio in audios) {
        if (audio.localPath != null) {
          final file = io.File(audio.localPath!);
          if (await file.exists()) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      debugPrint('[AudioRepository] Error clearing cache: $e');
    }
  }

  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final count = await _audioDao.getAudioCount();
      int totalSize = 0;

      final audios = await _audioDao.getDownloadedAudios();
      for (final audio in audios) {
        if (audio.localPath != null) {
          final file = io.File(audio.localPath!);
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
      debugPrint('[AudioRepository] Error getting cache stats: $e');
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

final audioRepositoryProvider = Provider<AudioRepository>((ref) {
  final audioDao = ref.watch(audioDaoProvider);
  final apiClient = ref.watch(apiClientProvider);

  return AudioRepository(audioDao: audioDao, apiClient: apiClient);
});
