// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_like.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentLike _$CommentLikeFromJson(Map<String, dynamic> json) => CommentLike(
  id: parseInt(json['id']),
  userId: _userIdToString(json['user_id']),
  commentId: _commentIdToString(json['comment_id']),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$CommentLikeToJson(CommentLike instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'comment_id': instance.commentId,
      'created_at': instance.createdAt.toIso8601String(),
    };
