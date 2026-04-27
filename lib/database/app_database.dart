import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:live_app/database/tables.dart';
import 'package:live_app/models/agent_support.dart';
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
    AgentSupports,
  ],
)
class AppDatabase extends _$AppDatabase {
  static final Map<String?, AppDatabase> _instances = {};

  factory AppDatabase.instance({String? userId}) {
    return _instances.putIfAbsent(userId, () => AppDatabase(userId: userId));
  }

  static Future<void> removeInstance(String? userId) async {
    final db = _instances.remove(userId);
    await db?.close();
  }

  final String? userId;

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
  int get schemaVersion => 10;

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
      if (from < 9) {
        // Support agent fields: recreate tables because
        // SQLite cannot ALTER COLUMN to remove NOT NULL.
        // This also covers users who were on v8 with the broken migration.

        // Recreate conversation_users with nullable user_id + new agent_support_id
        await customStatement('''
          CREATE TABLE conversation_users_new (
            id INTEGER NOT NULL PRIMARY KEY,
            conversation_id INTEGER NOT NULL,
            user_id TEXT,
            agent_support_id TEXT,
            role TEXT NOT NULL DEFAULT 'member',
            joined_at INTEGER NOT NULL
          )
        ''');
        await customStatement('''
          INSERT INTO conversation_users_new (id, conversation_id, user_id, role, joined_at)
          SELECT id, conversation_id, user_id, role, joined_at FROM conversation_users
        ''');
        await customStatement('DROP TABLE conversation_users');
        await customStatement(
          'ALTER TABLE conversation_users_new RENAME TO conversation_users',
        );

        // Recreate messages with nullable sender_id + new sender_support_id
        await customStatement('''
          CREATE TABLE messages_new (
            id INTEGER NOT NULL PRIMARY KEY,
            conversation_id INTEGER NOT NULL,
            sender_id TEXT,
            sender_support_id TEXT,
            content TEXT NOT NULL,
            message_type TEXT NOT NULL,
            is_revoked INTEGER NOT NULL,
            is_read INTEGER NOT NULL DEFAULT 0,
            media_url TEXT,
            thumbnail TEXT,
            duration INTEGER,
            created_at INTEGER NOT NULL,
            updated_at INTEGER,
            is_self INTEGER NOT NULL DEFAULT 0,
            send_failed INTEGER NOT NULL DEFAULT 0,
            revoked_at INTEGER
          )
        ''');
        await customStatement('''
          INSERT INTO messages_new (id, conversation_id, sender_id, content, message_type, is_revoked, is_read, media_url, thumbnail, duration, created_at, updated_at, is_self, send_failed, revoked_at)
          SELECT id, conversation_id, sender_id, content, message_type, is_revoked, is_read, media_url, thumbnail, duration, created_at, updated_at, is_self, send_failed, revoked_at FROM messages
        ''');
        await customStatement('DROP TABLE messages');
        await customStatement('ALTER TABLE messages_new RENAME TO messages');
      }
      if (from < 10) {
        await m.createTable(agentSupports);
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
