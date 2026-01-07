import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class EmojiFileService {
  final Dio _dio;
  static const String _emojiDir = 'emojis';
  static const String _gifDir = 'gifs';

  EmojiFileService(this._dio);

  Future<Directory> _getStorageDirectory() async {
    final appDir = await getApplicationSupportDirectory();
    return appDir;
  }

  Future<Directory> _getTypeDirectory(int type) async {
    final baseDir = await _getStorageDirectory();
    final subDir = type == 1 ? _emojiDir : _gifDir;
    final dir = Directory(path.join(baseDir.path, subDir));

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    return dir;
  }

  String _generateFilename(String url) {
    final bytes = url.codeUnits;
    final digest = md5.convert(bytes);
    final extension = path.extension(url).split('?').first;
    return '$digest$extension';
  }

  Future<String?> downloadFile({
    required String url,
    required int type,
    required int emojiId,
    void Function(double progress)? onProgress,
  }) async {
    if (kIsWeb)
      return null; // For now emoji files are handled via network on Web
    try {
      final dir = await _getTypeDirectory(type);
      final filename = _generateFilename(url);
      final filePath = path.join(dir.path, filename);
      final file = File(filePath);

      if (await file.exists()) {
        return filePath;
      }

      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            final progress = received / total;
            onProgress(progress);
          }
        },
      );

      return filePath;
    } catch (e) {
      debugPrint('[EmojiFileService] Error downloading emoji $emojiId: $e');
      return null;
    }
  }

  Future<Map<int, String>> downloadBatch({
    required List<({int id, String url, int type})> files,
    void Function(int completed, int total)? onProgress,
  }) async {
    final results = <int, String>{};
    var completed = 0;

    for (final file in files) {
      final localPath = await downloadFile(
        url: file.url,
        type: file.type,
        emojiId: file.id,
      );

      if (localPath != null) {
        results[file.id] = localPath;
      }

      completed++;
      onProgress?.call(completed, files.length);
    }

    return results;
  }

  Future<bool> fileExists(String localPath) async {
    final file = File(localPath);
    return await file.exists();
  }

  Future<bool> deleteFile(String localPath) async {
    try {
      final file = File(localPath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[EmojiFileService] Error deleting file: $e');
      return false;
    }
  }

  Future<void> clearCache(int type) async {
    try {
      final dir = await _getTypeDirectory(type);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('[EmojiFileService] Error clearing cache: $e');
    }
  }

  Future<void> clearAllCache() async {
    await clearCache(1); // Emojis
    await clearCache(2); // GIFs
  }

  Future<int> getCacheSize() async {
    if (kIsWeb) return 0;
    int totalSize = 0;

    try {
      final emojiDir = await _getTypeDirectory(1);
      final gifDir = await _getTypeDirectory(2);

      totalSize += await _getDirectorySize(emojiDir);
      totalSize += await _getDirectorySize(gifDir);
    } catch (e) {
      debugPrint('[EmojiFileService] Error calculating cache size: $e');
    }

    return totalSize;
  }

  Future<int> _getDirectorySize(Directory dir) async {
    int size = 0;

    if (!await dir.exists()) return 0;

    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        size += await entity.length();
      }
    }

    return size;
  }

  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
