import 'package:live_app/models/album_audio.dart';
import 'package:live_app/models/audio_category.dart';
import 'package:live_app/models/audio_creator.dart';
import 'package:live_app/models/audio_sub_category.dart';
import 'package:live_app/models/track_audio.dart';

import 'audio_title.dart';

class Audio {
  final int id;
  final String ref;
  final String title;
  final String description;
  final String? checking;
  final String? processing;
  final String? comment;
  final String userId;
  final int duration;
  final int audioCategoryId;
  final int audioSubCategoryId;
  final String cover;
  final String s3CoverPath;
  final int coverUploadStatus;
  final String localCoverPath;
  final String audioFile;
  final String s3AudioPath;
  final String localHlsPath;
  final String s3HlsPath;
  final int audioUploadStatus;
  final String localAudioPath;
  final String hash;
  final String sysCode;
  final bool sendToServer;
  final bool needVip;
  final String? creator;
  final int? creatorId;
  final bool isDeleted;
  final int plateformId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<AudioTitle> titles;
  final AudioCategory audioCategory;
  final AudioSubCategory? audioSubCategory;
  final AudioCreator? creatorObj;
  final List<TrackAudio> tracks;
  final String s3CoverUrl;
  final String s3HlsUrl;
  final String s3AudioUrl;
  final AlbumAudio? album;

  Audio({
    required this.id,
    required this.ref,
    required this.title,
    required this.description,
    this.checking,
    this.processing,
    this.comment,
    required this.userId,
    required this.duration,
    required this.audioCategoryId,
    required this.audioSubCategoryId,
    required this.cover,
    required this.s3CoverPath,
    required this.coverUploadStatus,
    required this.localCoverPath,
    required this.audioFile,
    required this.s3AudioPath,
    required this.localHlsPath,
    required this.s3HlsPath,
    required this.audioUploadStatus,
    required this.localAudioPath,
    required this.hash,
    required this.sysCode,
    required this.sendToServer,
    required this.needVip,
    this.creator,
    this.creatorId,
    required this.isDeleted,
    required this.plateformId,
    required this.createdAt,
    required this.updatedAt,
    required this.titles,
    required this.audioCategory,
    this.audioSubCategory,
    this.creatorObj,
    required this.tracks,
    required this.s3CoverUrl,
    required this.s3HlsUrl,
    required this.s3AudioUrl,
    this.album,
  });

  factory Audio.fromJson(Map<String, dynamic> json) {
    return Audio(
      id: json['id'],
      ref: json['ref'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      checking: json['checking'],
      processing: json['processing'],
      comment: json['comment'],
      userId: json['user_id'],
      duration: json['duration'] ?? 0,
      audioCategoryId: json['audio_category_id'] ?? 0,
      audioSubCategoryId: json['audio_sub_category_id'] ?? 0,
      cover: json['cover'] ?? '',
      s3CoverPath: json['s3_cover_path'] ?? '',
      coverUploadStatus: json['cover_upload_status'] ?? 0,
      localCoverPath: json['local_cover_path'] ?? '',
      audioFile: json['audio_file'] ?? '',
      s3AudioPath: json['s3_audio_path'] ?? '',
      localHlsPath: json['local_hls_path'] ?? '',
      s3HlsPath: json['s3_hls_path'] ?? '',
      audioUploadStatus: json['audio_upload_status'] ?? 0,
      localAudioPath: json['local_audio_path'] ?? '',
      hash: json['hash'] ?? '',
      sysCode: json['sys_code'] ?? '',
      sendToServer: json['sendToServer'] ?? false,
      needVip: json['need_vip'] ?? false,
      creator: json['creator'],
      creatorId: json['creator_id'],
      isDeleted: json['isDeleted'] ?? false,
      plateformId: json['plateform_id'] ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      titles: (json['titles'] as List<dynamic>)
          .map((e) => AudioTitle.fromJson(e))
          .toList(),
      audioCategory: AudioCategory.fromJson(json['audioCategory']),

      audioSubCategory: json['audioSubCategory'] != null
          ? AudioSubCategory.fromJson(json['audioSubCategory'])
          : null,
      creatorObj: json['creatorObj'] != null
          ? AudioCreator.fromJson(json['creatorObj'])
          : null,
      tracks: (json['tracks'] as List<dynamic>? ?? [])
          .map((e) => TrackAudio.fromJson(e))
          .toList(),
      s3CoverUrl: json['s3_cover_url'] ?? '',
      s3HlsUrl: json['s3_hls_url'] ?? '',
      s3AudioUrl: json['s3_audio_url'] ?? '',
      album: json['album'] != null ? AlbumAudio.fromJson(json['album']) : null,
    );
  }
}
