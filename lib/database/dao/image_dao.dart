import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/image_cache.dart';
import '../../provider/current_user_provider.dart';
import '../app_database.dart';
import '../tables.dart';

part 'image_dao.g.dart';

@DriftAccessor(tables: [Images])
class ImageDao extends DatabaseAccessor<AppDatabase> with _$ImageDaoMixin {
  ImageDao(super.db);

  Future<ImageCache?> getImageByUrl(String url) {
    return (select(images)..where((i) => i.url.equals(url))).getSingleOrNull();
  }

  Future<void> upsertImage(ImageCache image) =>
      into(images).insertOnConflictUpdate(image.toCompanion());

  Future<void> updateImageLocalPath(String url, String localPath) async {
    await (update(images)..where((i) => i.url.equals(url))).write(
      ImagesCompanion(localPath: Value(localPath)),
    );
  }

  Future<void> deleteImage(String url) async {
    await (delete(images)..where((i) => i.url.equals(url))).go();
  }

  Future<void> deleteAllImages() async {
    await delete(images).go();
  }

  Future<int> getImageCount() async {
    final count = countAll();
    final query = selectOnly(images)..addColumns([count]);

    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  Future<List<ImageCache>> getDownloadedImages() {
    return (select(images)..where((i) => i.localPath.isNotNull())).get();
  }

  Future<List<ImageCache>> getNotDownloadedImages() {
    return (select(images)..where((i) => i.localPath.isNull())).get();
  }
}

extension on ImageCache {
  ImagesCompanion toCompanion() {
    return ImagesCompanion(url: Value(url), localPath: Value(localPath));
  }
}

final imageDaoProvider = Provider<ImageDao>((ref) {
  final db = ref.watch(currentUserDatabaseProvider);
  return ImageDao(db);
});
