import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/audio_cache.dart';
import '../../provider/current_user_provider.dart';
import '../app_database.dart';
import '../tables.dart';

part 'audio_dao.g.dart';

@DriftAccessor(tables: [Audios])
class AudioDao extends DatabaseAccessor<AppDatabase> with _$AudioDaoMixin {
  AudioDao(super.db);

  Future<AudioCache?> getAudioByUrl(String url) {
    return (select(audios)..where((a) => a.url.equals(url))).getSingleOrNull();
  }

  Future<void> upsertAudio(AudioCache audio) =>
      into(audios).insertOnConflictUpdate(audio.toCompanion());

  Future<void> updateAudioLocalPath(String url, String localPath) async {
    await (update(audios)..where((a) => a.url.equals(url))).write(
      AudiosCompanion(localPath: Value(localPath)),
    );
  }

  Future<void> deleteAudio(String url) async {
    await (delete(audios)..where((a) => a.url.equals(url))).go();
  }

  Future<void> deleteAllAudios() async {
    await delete(audios).go();
  }

  Future<int> getAudioCount() async {
    final count = countAll();
    final query = selectOnly(audios)..addColumns([count]);

    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  Future<List<AudioCache>> getDownloadedAudios() {
    return (select(audios)..where((a) => a.localPath.isNotNull())).get();
  }

  Future<List<AudioCache>> getNotDownloadedAudios() {
    return (select(audios)..where((a) => a.localPath.isNull())).get();
  }
}

extension on AudioCache {
  AudiosCompanion toCompanion() {
    return AudiosCompanion(url: Value(url), localPath: Value(localPath));
  }
}

final audioDaoProvider = Provider<AudioDao>((ref) {
  final db = ref.watch(currentUserDatabaseProvider);
  return AudioDao(db);
});
