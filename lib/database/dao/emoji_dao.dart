import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/emoji_cache.dart';
import '../../provider/current_user_provider.dart';
import '../app_database.dart';
import '../tables.dart';

part 'emoji_dao.g.dart';

@DriftAccessor(tables: [Emojis, EmojiSyncMetadata])
class EmojiDao extends DatabaseAccessor<AppDatabase> with _$EmojiDaoMixin {
  EmojiDao(super.db);

  /// Get all cached emojis of a specific type
  Future<List<EmojiCache>> getEmojisByType(int type) {
    return (select(emojis)
          ..where((e) => e.type.equals(type))
          ..orderBy([(e) => OrderingTerm.asc(e.id)]))
        .get();
  }

  /// Watch emojis of a specific type (for real-time updates)
  Stream<List<EmojiCache>> watchEmojisByType(int type) {
    return (select(emojis)
          ..where((e) => e.type.equals(type))
          ..orderBy([(e) => OrderingTerm.asc(e.id)]))
        .watch();
  }

  /// Get a specific emoji by ID
  Future<EmojiCache?> getEmojiById(int id) {
    return (select(emojis)..where((e) => e.id.equals(id))).getSingleOrNull();
  }

  /// Get emoji by code
  Future<EmojiCache?> getEmojiByCode(String code) {
    return (select(
      emojis,
    )..where((e) => e.code.equals(code))).getSingleOrNull();
  }

  /// Insert or update an emoji
  Future<void> upsertEmoji(EmojiCache emoji) =>
      into(emojis).insertOnConflictUpdate(emoji.toCompanion());

  /// Insert or update multiple emojis
  Future<void> upsertEmojis(List<EmojiCache> emojiList) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(
        emojis,
        emojiList.map((e) => e.toCompanion()).toList(),
      );
    });
  }

  /// Update local path after file download
  Future<void> updateEmojiLocalPath(int id, String localPath) async {
    await (update(emojis)..where((e) => e.id.equals(id))).write(
      EmojisCompanion(
        localPath: Value(localPath),
        downloadedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Delete emoji by ID
  Future<void> deleteEmoji(int id) async {
    await (delete(emojis)..where((e) => e.id.equals(id))).go();
  }

  /// Delete all emojis of a specific type
  Future<void> deleteEmojisByType(int type) async {
    await (delete(emojis)..where((e) => e.type.equals(type))).go();
  }

  /// Get count of cached emojis by type
  Future<int> getEmojiCountByType(int type) async {
    final count = countAll();
    final query = selectOnly(emojis)
      ..addColumns([count])
      ..where(emojis.type.equals(type));

    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  /// Get emojis that haven't been downloaded yet
  Future<List<EmojiCache>> getNotDownloadedEmojis(int type) {
    return (select(emojis)
          ..where((e) => e.type.equals(type) & e.localPath.isNull())
          ..orderBy([(e) => OrderingTerm.asc(e.id)]))
        .get();
  }

  /// Get sync metadata for a specific type
  Future<EmojiSyncMeta?> getSyncMetadata(int type) {
    return (select(
      emojiSyncMetadata,
    )..where((m) => m.type.equals(type))).getSingleOrNull();
  }

  /// Update sync metadata after successful sync
  Future<void> updateSyncMetadata(int type, int totalCount) async {
    await into(emojiSyncMetadata).insertOnConflictUpdate(
      EmojiSyncMetadataCompanion(
        type: Value(type),
        lastSyncAt: Value(DateTime.now()),
        totalCount: Value(totalCount),
      ),
    );
  }

  /// Check if we need to sync (e.g., if last sync was more than X time ago)
  Future<bool> shouldSync(int type, Duration maxAge) async {
    final meta = await getSyncMetadata(type);
    if (meta == null) return true; // Never synced

    final age = DateTime.now().difference(meta.lastSyncAt);
    return age > maxAge;
  }

  /// Clear all sync metadata
  Future<void> clearSyncMetadata() async {
    await delete(emojiSyncMetadata).go();
  }

  /// Clear all emoji data (for testing or reset)
  Future<void> clearAllEmojis() async {
    await delete(emojis).go();
    await delete(emojiSyncMetadata).go();
  }

  /// Get total storage size estimate
  Future<int> getStorageEstimate() async {
    final allEmojis = await select(emojis).get();
    // Rough estimate: count emojis with local files
    return allEmojis.where((e) => e.localPath != null).length;
  }
}

extension on EmojiCache {
  EmojisCompanion toCompanion() {
    return EmojisCompanion(
      id: Value(id),
      code: Value(code),
      url: Value(url),
      type: Value(type),
      status: Value(status),
      groupId: Value(groupId),
      groupName: Value(groupName),
      groupPrice: Value(groupPrice),
      groupIsPremium: Value(groupIsPremium),
      purchased: Value(purchased),
      localPath: Value(localPath),
      downloadedAt: Value(downloadedAt),
      updatedAt: Value(updatedAt),
      createdAt: Value(createdAt),
    );
  }
}

final emojiDaoProvider = Provider<EmojiDao>((ref) {
  final db = ref.watch(currentUserDatabaseProvider);
  return EmojiDao(db);
});
