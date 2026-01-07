import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:live_app/database/tables.dart';
import 'package:live_app/models/video_cache.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod/riverpod.dart';

import '../models/audio_cache.dart';
import '../models/conversation.dart';
import '../models/conversation_user.dart';
import '../models/emoji_cache.dart';
import '../models/image_cache.dart';
import '../models/message.dart';
import '../models/userinfo.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Conversations,
    ConversationUsers,
    Messages,
    UserInfos,
    Emojis,
    EmojiSyncMetadata,
    Images,
    Audios,
    Videos,
  ],
)
class AppDatabase extends _$AppDatabase {
  final int? userId;

  AppDatabase({this.userId, QueryExecutor? e})
    : super(
        e ??
            driftDatabase(
              name: userId != null ? 'chat_user_$userId' : 'chat',
              native: const DriftNativeOptions(
                databaseDirectory: getApplicationSupportDirectory,
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
            ),
      );

  AppDatabase.forTesting(DatabaseConnection super.connection) : userId = null;

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 4) {
        await m.createTable(emojis);
        await m.createTable(emojiSyncMetadata);
      }
      if (from < 5) {
        await m.createTable(images);
      }
      if (from < 6) {
        await m.createTable(audios);
      }
      if (from < 7) {
        await m.createTable(videos);
      }
    },
  );

  @Deprecated('Use currentUserDatabaseProvider from current_user_provider.dart')
  static final provider = Provider<AppDatabase>((ref) {
    final db = AppDatabase();
    ref.onDispose(db.close);
    return db;
  });
}
