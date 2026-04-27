// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emoji_dao.dart';

// ignore_for_file: type=lint
mixin _$EmojiDaoMixin on DatabaseAccessor<AppDatabase> {
  $EmojisTable get emojis => attachedDatabase.emojis;
  $EmojiSyncMetadataTable get emojiSyncMetadata =>
      attachedDatabase.emojiSyncMetadata;
  EmojiDaoManager get managers => EmojiDaoManager(this);
}

class EmojiDaoManager {
  final _$EmojiDaoMixin _db;
  EmojiDaoManager(this._db);
  $$EmojisTableTableManager get emojis =>
      $$EmojisTableTableManager(_db.attachedDatabase, _db.emojis);
  $$EmojiSyncMetadataTableTableManager get emojiSyncMetadata =>
      $$EmojiSyncMetadataTableTableManager(
        _db.attachedDatabase,
        _db.emojiSyncMetadata,
      );
}
