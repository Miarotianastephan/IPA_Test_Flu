import 'package:json_annotation/json_annotation.dart';
import 'version.dart';

part 'version_response.g.dart';

@JsonSerializable()
class VersionResponse {
  final int code;
  final String msg;
  final Version data;

  VersionResponse({
    required this.code,
    required this.msg,
    required this.data,
  });

  factory VersionResponse.fromJson(Map<String, dynamic> json) =>
      _$VersionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$VersionResponseToJson(this);
}
