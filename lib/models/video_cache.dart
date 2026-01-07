import 'package:json_annotation/json_annotation.dart';

part 'video_cache.g.dart';

@JsonSerializable()
class VideoCache {
  final String url;
  final String? localPath;

  VideoCache({required this.url, this.localPath});

  factory VideoCache.fromJson(Map<String, dynamic> json) =>
      _$VideoCacheFromJson(json);
  Map<String, dynamic> toJson() => _$VideoCacheToJson(this);

  VideoCache copyWith({String? url, String? localPath}) {
    return VideoCache(
      url: url ?? this.url,
      localPath: localPath ?? this.localPath,
    );
  }
}
