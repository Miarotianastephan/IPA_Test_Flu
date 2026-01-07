// lib/providers/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/database/download_database.dart';
import 'package:live_app/database/offline_repository.dart';

final dbProvider = Provider<AppDatabaseDownload>(
  (ref) => AppDatabaseDownload(),
);

final offlineRepoProvider = Provider<OfflineRepository>((ref) {
  final db = ref.watch(dbProvider);
  return OfflineRepository(db);
});
final downloadsStreamProvider = StreamProvider<List<Download>>((ref) {
  final repo = ref.watch(offlineRepoProvider);
  return repo.watchAll();
});
final usedSpaceProvider = StreamProvider<int>((ref) {
  final repo = ref.watch(offlineRepoProvider);
  return repo.db.watchAll().map((downloads) {
    return downloads.fold<int>(0, (sum, d) => sum + (d.sizeBytes ?? 0));
  });
});
final isStorageSaturatedProvider = FutureProvider<bool>((ref) {
  final repo = ref.watch(offlineRepoProvider);
  return repo.isStorageSaturated();
});
final preparedProvider = StateProvider.family<bool, int>((ref, videoId) {
  return false;
});
final preparingProvider = StateProvider.family<bool, int>((ref, videoId) {
  return false;
});
final progressProvider = StateProvider.family<int, int>((ref, videoId) {
  return 0;
});
