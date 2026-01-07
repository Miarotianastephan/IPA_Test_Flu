import 'package:json_annotation/json_annotation.dart';

part 'hls_playback_info.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class HlsPlaybackInfo {
  final String m3u8Content;

  HlsPlaybackInfo({required this.m3u8Content});

  factory HlsPlaybackInfo.fromJson(Map<String, dynamic> json) =>
      _$HlsPlaybackInfoFromJson(json);

  Map<String, dynamic> toJson() => _$HlsPlaybackInfoToJson(this);
}
