import 'package:live_app/models/album_audio_title.dart';
import 'package:live_app/models/track_audio.dart';

class AlbumAudio {
  final int id;
  final String ref;
  final int albumNumber;
  final int totalTracks;
  final DateTime releaseDate;
  final int audioId;
  final String userId;
  final Map<String, dynamic> metadata;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? creatorId;
  final int plateformId;
  final int? audioCategoryId;
  final int? audioSubCategoryId;
  final List<AlbumAudioTitle> titles;
  final List<TrackAudio> tracks;

  AlbumAudio({
    required this.id,
    required this.ref,
    required this.albumNumber,
    required this.totalTracks,
    required this.releaseDate,
    required this.audioId,
    required this.userId,
    required this.metadata,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    this.creatorId,
    required this.plateformId,
    this.audioCategoryId,
    this.audioSubCategoryId,
    required this.titles,
    required this.tracks,
  });

  factory AlbumAudio.fromJson(Map<String, dynamic> json) {
    return AlbumAudio(
      id: json['id'],
      ref: json['ref'] ?? '',
      albumNumber: json['album_number'] ?? 0,
      totalTracks: json['total_tracks'] ?? 0,
      releaseDate:
          DateTime.tryParse(json['release_date'] ?? '') ?? DateTime.now(),
      audioId: json['audio_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      metadata: json['metadata'] ?? {},
      isDeleted: json['isDeleted'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      creatorId: json['creator_id'],
      plateformId: json['plateform_id'] ?? 0,
      audioCategoryId: json['audio_category_id'],
      audioSubCategoryId: json['audio_sub_category_id'],
      titles: (json['titles'] as List<dynamic>)
          .map((e) => AlbumAudioTitle.fromJson(e))
          .toList(),
      tracks: (json['tracks'] as List<dynamic>)
          .map((e) => TrackAudio.fromJson(e))
          .toList(),
    );
  }
}
