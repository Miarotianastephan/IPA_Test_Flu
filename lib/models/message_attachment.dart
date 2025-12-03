import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'message_attachment.g.dart';

@JsonSerializable(explicitToJson: true)
class MessageAttachment {
  final int id;

  @JsonKey(name: "message_id")
  final int messageId;

  @JsonKey(name: "file_url")
  final String fileUrl;

  @JsonKey(name: "file_type")
  final String fileType;

  @JsonKey(name: "file_size")
  final int? fileSize;

  @JsonKey(name: "created_at")
  final DateTime createdAt;

  MessageAttachment({
    required this.id,
    required this.messageId,
    required this.fileUrl,
    required this.fileType,
    this.fileSize,
    required this.createdAt,
  });

  factory MessageAttachment.fromJson(Map<String, dynamic> json) =>
      _$MessageAttachmentFromJson(json);

  Map<String, dynamic> toJson() => _$MessageAttachmentToJson(this);

  MessageAttachment copyWith({
    int? id,
    int? messageId,
    String? fileUrl,
    String? fileType,
    int? fileSize,
    DateTime? createdAt,
  }) =>
      MessageAttachment(
        id: id ?? this.id,
        messageId: messageId ?? this.messageId,
        fileUrl: fileUrl ?? this.fileUrl,
        fileType: fileType ?? this.fileType,
        fileSize: fileSize ?? this.fileSize,
        createdAt: createdAt ?? this.createdAt,
      );
}

extension MessageAttachmentJsonString on MessageAttachment {
  String toJsonString() => jsonEncode(toJson());
}

class MessageAttachmentJsonParse {
  static MessageAttachment fromJsonString(String jsonStr) =>
      MessageAttachment.fromJson(jsonDecode(jsonStr));
}