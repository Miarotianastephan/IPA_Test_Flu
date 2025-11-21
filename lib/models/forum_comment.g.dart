// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forum_comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ForumComment _$ForumCommentFromJson(Map<String, dynamic> json) => ForumComment(
  id: parseInt(json['id']),
  postId: parseInt(json['post_id']),
  userId: parseInt(json['user_id']),
  parentId: parseInt(json['parent_id']),
  content: json['content'] as String,
  upvoteCount: parseInt(json['upvote_count']),
  downvoteCount: parseInt(json['downvote_count']),
  status: json['status'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
  post: json['post'] == null
      ? null
      : ForumPost.fromJson(json['post'] as Map<String, dynamic>),
  parent: json['parent'] == null
      ? null
      : ForumComment.fromJson(json['parent'] as Map<String, dynamic>),
  childCount: parseInt(json['child_count']),
  isLike: parseBool(json['is_like']),
  isDownVote: parseBool(json['is_down_vote']),
  commentUser: json['comment_user'] == null
      ? null
      : CommentUser.fromJson(json['comment_user'] as Map<String, dynamic>),
  commentToUser: json['comment_to_user'] == null
      ? null
      : CommentUser.fromJson(json['comment_to_user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ForumCommentToJson(ForumComment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'post_id': instance.postId,
      'user_id': instance.userId,
      'parent_id': instance.parentId,
      'content': instance.content,
      'upvote_count': instance.upvoteCount,
      'downvote_count': instance.downvoteCount,
      'status': instance.status,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'post': instance.post?.toJson(),
      'parent': instance.parent?.toJson(),
      'child_count': instance.childCount,
      'is_like': instance.isLike,
      'is_down_vote': instance.isDownVote,
      'comment_user': instance.commentUser?.toJson(),
      'comment_to_user': instance.commentToUser?.toJson(),
    };

CommentUser _$CommentUserFromJson(Map<String, dynamic> json) => CommentUser(
  id: parseInt(json['id']),
  nickname: json['nickname'] as String,
  avatar: json['avatar'] as String?,
);

Map<String, dynamic> _$CommentUserToJson(CommentUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nickname': instance.nickname,
      'avatar': instance.avatar,
    };
