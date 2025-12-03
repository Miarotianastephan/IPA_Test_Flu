import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/models/userinfo.dart';
import 'package:live_app/utils/json_utils.dart';

import 'comment_like.dart';

part 'video_comment.g.dart';

@JsonSerializable(explicitToJson: true)
class VideoComment {
  @JsonKey(fromJson: parseInt)
  final int id;
  @JsonKey(name: 'video_id', fromJson: parseInt)
  final int videoId;
  @JsonKey(name: 'user_id', fromJson: parseInt)
  final int userId;
  final String content;
  @JsonKey(name: 'parent_id', fromJson: parseInt)
  final int? parentId;
  @JsonKey(name: 'like_count', fromJson: parseInt)
  final int likeCount;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'child_count', fromJson: parseInt)
  final int childCount;
  @JsonKey(name: 'is_like', fromJson: parseBool)
  final bool isLike;
  @JsonKey(name: 'comment_user')
  //comment_user
  // SimpleUSer
  final UserInfo? commentUser;
  @JsonKey(name: 'comment_to_user')
  final UserInfo? commentToUser;
  @JsonKey(name: 'v_comment_likes')
  final List<CommentLike>? vCommentLikes;

  VideoComment({
    required this.id,
    required this.videoId,
    required this.userId,
    required this.content,
    this.parentId,
    required this.likeCount,
    required this.createdAt,
    required this.childCount,
    required this.isLike,
    this.commentUser,
    this.commentToUser,
    this.vCommentLikes,
  });

  factory VideoComment.fromJson(Map<String, dynamic> json) {
    try {
      final result = _$VideoCommentFromJson(json);
      return result;
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => _$VideoCommentToJson(this);
}
