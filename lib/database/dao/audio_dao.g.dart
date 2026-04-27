// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_dao.dart';

// ignore_for_file: type=lint
mixin _$AudioDaoMixin on DatabaseAccessor<AppDatabase> {
  $AudiosTable get audios => attachedDatabase.audios;
  AudioDaoManager get managers => AudioDaoManager(this);
}

class AudioDaoManager {
  final _$AudioDaoMixin _db;
  AudioDaoManager(this._db);
  $$AudiosTableTableManager get audios =>
      $$AudiosTableTableManager(_db.attachedDatabase, _db.audios);
}
