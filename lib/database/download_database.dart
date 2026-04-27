import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

part 'download_database.g.dart';

enum DownloadStatus {
  pending,
  downloading,
  paused,
  completed,
  failed,
  cancelled,
}

class Downloads extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get type => text()();
  IntColumn get durationSeconds => integer().nullable()();
  TextColumn get url => text()();
  TextColumn get localPath => text().nullable()();
  IntColumn get progress => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant("pending"))();
  IntColumn get sizeBytes => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get coverUrl => text()();
  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Downloads])
class AppDatabaseDownload extends _$AppDatabaseDownload {
  AppDatabaseDownload() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.deleteTable('downloads');
        await migrator.createTable(downloads);
      }
    },
  );

  Future<int> insertDownload(DownloadsCompanion entry) =>
      into(downloads).insert(entry);

  Stream<List<Download>> watchAll() => select(downloads).watch();

  Stream<List<Download>> watchByType(String type) =>
      (select(downloads)..where((t) => t.type.equals(type))).watch();

  Future<Download?> getById(String id) =>
      (select(downloads)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<Download?> watchById(String id) =>
      (select(downloads)..where((t) => t.id.equals(id))).watchSingleOrNull();

  // Mise à jour partielle
  Future<void> updateFields(String id, DownloadsCompanion entry) async {
    await (update(downloads)..where((t) => t.id.equals(id))).write(entry);
  }

  Future<void> deleteById(String id) async =>
      (delete(downloads)..where((t) => t.id.equals(id))).go();

  Future<List<Download>> all() => select(downloads).get();

  Future<void> deleteAll() async => delete(downloads).go();
}

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'downloads',
    native: const DriftNativeOptions(
      databaseDirectory: getApplicationDocumentsDirectory,
    ),
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
      onResult: (result) {
        if (result.missingFeatures.isNotEmpty) {
          debugPrint(
            'Using ${result.chosenImplementation} due to unsupported '
            'browser features: ${result.missingFeatures}',
          );
        }
      },
    ),
  );
}
