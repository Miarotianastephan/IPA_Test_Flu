class TrackAudio {
  final int id;
  final int trackNumber;
  final String title;
  final String description;
  final String audioFile;
  final String s3HlsPath;
  final int audioUploadStatus;
  final String localAudioPath;
  final String localHlsPath;
  final String hash;
  final String sysCode;
  final String? lyrics;
  final String? s3HlsUrl;

  TrackAudio({
    required this.id,
    required this.trackNumber,
    required this.title,
    required this.description,
    required this.audioFile,
    required this.s3HlsPath,
    required this.audioUploadStatus,
    required this.localAudioPath,
    required this.localHlsPath,
    required this.hash,
    required this.sysCode,
    this.lyrics,
    this.s3HlsUrl,
  });

  factory TrackAudio.fromJson(Map<String, dynamic> json) {
    return TrackAudio(
      id: json['id'],
      trackNumber: json['track_number'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      audioFile: json['audio_file'] ?? '',
      s3HlsPath: json['s3_hls_path'] ?? '',
      audioUploadStatus: json['audio_upload_status'] ?? 0,
      localAudioPath: json['local_audio_path'] ?? '',
      localHlsPath: json['local_hls_path'] ?? '',
      hash: json['hash'] ?? '',
      sysCode: json['sys_code'] ?? '',
      lyrics: json['lyrics'],
      s3HlsUrl: json['s3_hls_url'],
    );
  }
}
