// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forum_attachment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ForumAttachment _$ForumAttachmentFromJson(Map<String, dynamic> json) =>
    ForumAttachment(
      id: parseInt(json['id']),
      postId: parseInt(json['post_id']),
      fileUrl: json['file_url'] as String,
      fileType: json['file_type'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$ForumAttachmentToJson(ForumAttachment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'post_id': instance.postId,
      'file_url': instance.fileUrl,
      'file_type': instance.fileType,
      'thumbnail_url': instance.thumbnailUrl,
      'created_at': instance.createdAt,
    };
