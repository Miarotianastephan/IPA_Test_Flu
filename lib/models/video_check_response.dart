import 'package:json_annotation/json_annotation.dart';

part 'video_check_response.g.dart';

enum VideoCheckStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('success')
  success,
  @JsonValue('paid')
  paid,
  @JsonValue('failed')
  failed,
  @JsonValue('expired')
  expired,
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VideoCheckResponse {
  final VideoCheckStatus status;

  VideoCheckResponse({required this.status});

  factory VideoCheckResponse.fromJson(Map<String, dynamic> json) =>
      _$VideoCheckResponseFromJson(json);

  Map<String, dynamic> toJson() => _$VideoCheckResponseToJson(this);

  bool get isPurchased =>
      status == VideoCheckStatus.success || status == VideoCheckStatus.paid;

  bool get isFinal =>
      status == VideoCheckStatus.success ||
      status == VideoCheckStatus.paid ||
      status == VideoCheckStatus.failed ||
      status == VideoCheckStatus.expired;
}
