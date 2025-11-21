import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/utils/json_utils.dart';

import 'forum_post.dart';

part 'forum_comment.g.dart';

@JsonSerializable(explicitToJson: true)
class ForumComment {
  @JsonKey(fromJson: parseInt)
  final int id;

  @JsonKey(name: 'post_id', fromJson: parseInt)
  final int postId;

  @JsonKey(name: 'user_id', fromJson: parseInt)
  final int userId;

  @JsonKey(name: 'parent_id', fromJson: parseInt)
  final int? parentId;

  final String content;

  @JsonKey(name: 'upvote_count', fromJson: parseInt)
  final int upvoteCount;

  @JsonKey(name: 'downvote_count', fromJson: parseInt)
  final int downvoteCount;

  final String status;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @JsonKey(name: 'deleted_at')
  final DateTime? deletedAt;

  final ForumPost? post;
  final ForumComment? parent;

  @JsonKey(name: 'child_count', fromJson: parseInt)
  final int childCount;

  @JsonKey(name: 'is_like', fromJson: parseBool)
  final bool isLike;

  @JsonKey(name: 'is_down_vote', fromJson: parseBool)
  final bool isDownVote;

  @JsonKey(name: 'comment_user')
  final CommentUser? commentUser;

  @JsonKey(name: 'comment_to_user')
  final CommentUser? commentToUser;

  ForumComment({
    required this.id,
    required this.postId,
    required this.userId,
    this.parentId,
    required this.content,
    required this.upvoteCount,
    required this.downvoteCount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.post,
    this.parent,
    required this.childCount,
    required this.isLike,
    required this.isDownVote,
    this.commentUser,
    this.commentToUser,
  });

  factory ForumComment.fromJson(Map<String, dynamic> json) =>
      _$ForumCommentFromJson(json);

  Map<String, dynamic> toJson() => _$ForumCommentToJson(this);
}

/// 评论的用户信息
@JsonSerializable(explicitToJson: true)
class CommentUser {
  @JsonKey(fromJson: parseInt)
  final int id;
  final String nickname;
  final String? avatar;

  CommentUser({required this.id, required this.nickname, this.avatar});

  factory CommentUser.fromJson(Map<String, dynamic> json) =>
      _$CommentUserFromJson(json);

  Map<String, dynamic> toJson() => _$CommentUserToJson(this);
}