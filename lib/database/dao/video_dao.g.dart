// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_dao.dart';

// ignore_for_file: type=lint
mixin _$VideoDaoMixin on DatabaseAccessor<AppDatabase> {
  $VideosTable get videos => attachedDatabase.videos;
  VideoDaoManager get managers => VideoDaoManager(this);
}

class VideoDaoManager {
  final _$VideoDaoMixin _db;
  VideoDaoManager(this._db);
  $$VideosTableTableManager get videos =>
      $$VideosTableTableManager(_db.attachedDatabase, _db.videos);
}
