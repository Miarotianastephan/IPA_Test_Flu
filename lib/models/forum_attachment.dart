import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/utils/json_utils.dart';

part 'forum_attachment.g.dart';

@JsonSerializable()
class ForumAttachment {
  @JsonKey(fromJson: parseInt)
  final int id;
  @JsonKey(name: 'post_id',fromJson: parseInt)
  final int postId;
  @JsonKey(name: 'file_url')
  final String fileUrl;
  @JsonKey(name: 'file_type')
  final String fileType;
  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;
  @JsonKey(name: 'created_at')
  final String createdAt;

  ForumAttachment({
    required this.id,
    required this.postId,
    required this.fileUrl,
    required this.fileType,
    this.thumbnailUrl,
    required this.createdAt,
  });

  factory ForumAttachment.fromJson(Map<String, dynamic> json) =>
      _$ForumAttachmentFromJson(json);

  Map<String, dynamic> toJson() => _$ForumAttachmentToJson(this);
}