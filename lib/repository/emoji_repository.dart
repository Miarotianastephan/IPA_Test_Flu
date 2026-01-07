import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/services/user_service.dart';
import '../database/dao/emoji_dao.dart';
import '../models/emoji.dart';
import '../models/emoji_cache.dart';
import '../models/page_params.dart';
import '../provider/api_provider.dart';
import '../services/emoji_file_service.dart';

/// Repository that manages emoji/GIF data from both local DB and API
/// Implements offline-first strategy with background sync
class EmojiRepository {
  final EmojiDao _emojiDao;
  final UserService _userService;
  final EmojiFileService _fileService;

  // Sync configuration
  static const Duration _syncInterval = Duration(hours: 1);
  static const int _pageSize = 20;

  EmojiRepository({
    required EmojiDao emojiDao,
    required UserService userService,
    required EmojiFileService fileService,
  })  : _emojiDao = emojiDao,
        _userService = userService,
        _fileService = fileService;

  // ========== PUBLIC API ==========

  /// Get emojis from local cache (fast, offline-first)
  /// Returns cached data immediately
  Future<List<Emoji>> getEmojis(int type) async {
    try {
      final cached = await _emojiDao.getEmojisByType(type);
      debugPrint(
          '[EmojiRepository] Loaded ${cached.length} emojis of type $type from cache');

      // Convert to API model with local paths
      return cached.map((c) => c.toEmoji()).toList();
    } catch (e) {
      debugPrint('[EmojiRepository] Error loading from cache: $e');
      return [];
    }
  }

  /// Watch emojis from local cache (reactive)
  Stream<List<Emoji>> watchEmojis(int type) {
    return _emojiDao
        .watchEmojisByType(type)
        .map((cached) => cached.map((c) => c.toEmoji()).toList());
  }

  /// Sync emojis with API
  /// - Fetches latest data from API
  /// - Updates local cache
  /// - Downloads missing files in background
  /// - Returns true if new data was synced
  Future<bool> syncEmojis(int type, {bool forceRefresh = false}) async {
    try {
      // Check if we need to sync
      if (!forceRefresh) {
        final shouldSync = await _emojiDao.shouldSync(type, _syncInterval);
        if (!shouldSync) {
          debugPrint(
              '[EmojiRepository] Skipping sync for type $type (too recent)');
          return false;
        }
      }

      debugPrint(
          '[EmojiRepository] Starting sync for type $type (force: $forceRefresh)');

      // Fetch all emojis from API (paginated)
      final allEmojis = await _fetchAllEmojisFromApi(type);

      if (allEmojis.isEmpty) {
        debugPrint('[EmojiRepository] No emojis received from API');
        return false;
      }

      debugPrint(
          '[EmojiRepository] Fetched ${allEmojis.length} emojis from API');

      // Convert to cache models
      final cacheModels =
          allEmojis.map((e) => EmojiCache.fromEmoji(e)).toList();

      // Update local database
      await _emojiDao.upsertEmojis(cacheModels);

      // Update sync metadata
      await _emojiDao.updateSyncMetadata(type, allEmojis.length);

      debugPrint('[EmojiRepository] Sync completed for type $type');

      // Download files in background (don't await)
      _downloadMissingFilesInBackground(type);

      return true;
    } catch (e) {
      debugPrint('[EmojiRepository] Error syncing type $type: $e');
      return false;
    }
  }

  /// Check if there are updates available from API
  /// Returns true if remote has more/different emojis
  Future<bool> hasUpdates(int type) async {
    try {
      final meta = await _emojiDao.getSyncMetadata(type);
      if (meta == null) return true; // Never synced

      // Fetch first page to get total count
      final response = await _userService.getEmojis(
        PageParams(page: 1, limit: 1, type: type),
      );

      if (response.code != 1 || response.data == null) {
        return false;
      }

      final remoteTotal = response.data!.total;
      return remoteTotal != meta.totalCount;
    } catch (e) {
      debugPrint('[EmojiRepository] Error checking updates: $e');
      return false;
    }
  }

  /// Clear all cached data for a type
  Future<void> clearCache(int type) async {
    await _emojiDao.deleteEmojisByType(type);
    await _fileService.clearCache(type);
    debugPrint('[EmojiRepository] Cleared cache for type $type');
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    final emojiCount = await _emojiDao.getEmojiCountByType(1);
    final gifCount = await _emojiDao.getEmojiCountByType(2);
    final cacheSize = await _fileService.getCacheSize();

    return {
      'emojiCount': emojiCount,
      'gifCount': gifCount,
      'totalSize': cacheSize,
      'formattedSize': EmojiFileService.formatBytes(cacheSize),
    };
  }

  // ========== PRIVATE HELPERS ==========

  /// Fetch all emojis from API with pagination
  Future<List<Emoji>> _fetchAllEmojisFromApi(int type) async {
    final allEmojis = <Emoji>[];
    int currentPage = 1;
    bool hasMore = true;

    while (hasMore) {
      final response = await _userService.getEmojis(
        PageParams(page: currentPage, limit: _pageSize, type: type),
      );

      if (response.code != 1 || response.data == null) {
        debugPrint('[EmojiRepository] API error: ${response.msg}');
        break;
      }

      final pageData = response.data!;
      allEmojis.addAll(pageData.list);

      // Check if there are more pages
      final totalPages = (pageData.total / pageData.limit).ceil();
      hasMore = currentPage < totalPages;
      currentPage++;

      debugPrint(
          '[EmojiRepository] Fetched page $currentPage/$totalPages (${allEmojis.length}/${pageData.total})');
    }

    return allEmojis;
  }

  /// Download missing files in background
  void _downloadMissingFilesInBackground(int type) async {
    try {
      final notDownloaded = await _emojiDao.getNotDownloadedEmojis(type);

      if (notDownloaded.isEmpty) {
        debugPrint(
            '[EmojiRepository] All files already downloaded for type $type');
        return;
      }

      debugPrint(
          '[EmojiRepository] Starting background download of ${notDownloaded.length} files');

      // Download in batches to avoid overloading
      const batchSize = 5;
      for (var i = 0; i < notDownloaded.length; i += batchSize) {
        final end = (i + batchSize < notDownloaded.length)
            ? i + batchSize
            : notDownloaded.length;
        final batch = notDownloaded.sublist(i, end);

        await _downloadBatch(batch);

        // Small delay between batches to avoid overwhelming the network
        if (end < notDownloaded.length) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      debugPrint('[EmojiRepository] Background download completed');
    } catch (e) {
      debugPrint('[EmojiRepository] Error in background download: $e');
    }
  }

  /// Download a batch of files
  Future<void> _downloadBatch(List<EmojiCache> batch) async {
    final files = batch
        .map((e) => (id: e.id, url: e.url, type: e.type))
        .toList();

    final results = await _fileService.downloadBatch(files: files);

    // Update database with local paths
    for (final entry in results.entries) {
      await _emojiDao.updateEmojiLocalPath(entry.key, entry.value);
    }

    debugPrint(
        '[EmojiRepository] Downloaded ${results.length}/${batch.length} files');
  }
}

/// Provider for EmojiRepository
final emojiRepositoryProvider = Provider<EmojiRepository>((ref) {
  final emojiDao = ref.watch(emojiDaoProvider);
  final userService = ref.watch(userServiceProvider);
  final fileService = ref.watch(emojiFileServiceProvider);

  return EmojiRepository(
    emojiDao: emojiDao,
    userService: userService,
    fileService: fileService,
  );
});
