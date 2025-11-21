// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoComment _$VideoCommentFromJson(Map<String, dynamic> json) => VideoComment(
  id: parseInt(json['id']),
  videoId: parseInt(json['video_id']),
  userId: parseInt(json['user_id']),
  content: json['content'] as String,
  parentId: parseInt(json['parent_id']),
  likeCount: parseInt(json['like_count']),
  createdAt: DateTime.parse(json['created_at'] as String),
  childCount: parseInt(json['child_count']),
  isLike: parseBool(json['is_like']),
  commentUser: json['comment_user'] == null
      ? null
      : UserInfo.fromJson(json['comment_user'] as Map<String, dynamic>),
  commentToUser: json['comment_to_user'] == null
      ? null
      : UserInfo.fromJson(json['comment_to_user'] as Map<String, dynamic>),
  vCommentLikes: (json['v_comment_likes'] as List<dynamic>?)
      ?.map((e) => CommentLike.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$VideoCommentToJson(
  VideoComment instance,
) => <String, dynamic>{
  'id': instance.id,
  'video_id': instance.videoId,
  'user_id': instance.userId,
  'content': instance.content,
  'parent_id': instance.parentId,
  'like_count': instance.likeCount,
  'created_at': instance.createdAt.toIso8601String(),
  'child_count': instance.childCount,
  'is_like': instance.isLike,
  'comment_user': instance.commentUser?.toJson(),
  'comment_to_user': instance.commentToUser?.toJson(),
  'v_comment_likes': instance.vCommentLikes?.map((e) => e.toJson()).toList(),
};
