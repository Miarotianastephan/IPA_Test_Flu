import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/database/app_database.dart';
import 'package:live_app/database/tables.dart';
import 'package:live_app/models/video_cache.dart';
import 'package:live_app/provider/current_user_provider.dart';

part 'video_dao.g.dart';

@DriftAccessor(tables: [Videos])
class VideoDao extends DatabaseAccessor<AppDatabase> with _$VideoDaoMixin {
  VideoDao(super.db);

  Future<VideoCache?> getVideoByUrl(String url) {
    return (select(videos)..where((i) => i.url.equals(url))).getSingleOrNull();
  }

  Future<void> upsertVideo(VideoCache video) =>
      into(videos).insertOnConflictUpdate(video.toCompanion());

  Future<void> updateVideoLocalPath(String url, String localPath) async {
    await (update(videos)..where((i) => i.url.equals(url))).write(
      VideosCompanion(localPath: Value(localPath)),
    );
  }

  Future<void> deleteVideo(String url) async {
    await (delete(videos)..where((i) => i.url.equals(url))).go();
  }

  Future<void> deleteAllVideos() async {
    await delete(videos).go();
  }

  Future<int> getVideoCount() async {
    final count = countAll();
    final query = selectOnly(videos)..addColumns([count]);

    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  Future<List<VideoCache>> getDownloadedVideos() {
    return (select(videos)..where((i) => i.localPath.isNotNull())).get();
  }
}

extension on VideoCache {
  VideosCompanion toCompanion() {
    return VideosCompanion(url: Value(url), localPath: Value(localPath));
  }
}

final videoDaoProvider = Provider<VideoDao>((ref) {
  final db = ref.watch(currentUserDatabaseProvider);
  return VideoDao(db);
});
