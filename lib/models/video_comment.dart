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


// import 'simple_user.dart';
//
// class VideoComment {
//   final int id;
//   final int videoId;
//   final int userId;
//   final String content;
//   final int? parentId;
//   final int likeCount;
//   final DateTime createdAt;
//   final int childCount;
//   final bool isLike;
//   final SimpleUser? commentUser;   // 评论者
//   final SimpleUser? commentToUser; // 被回复者
//
//   VideoComment({
//     required this.id,
//     required this.videoId,
//     required this.userId,
//     required this.content,
//     this.parentId,
//     required this.likeCount,
//     required this.createdAt,
//     required this.childCount,
//     required this.isLike,
//     this.commentUser,
//     this.commentToUser,
//   });
//
//   factory VideoComment.fromJson(Map<String, dynamic> json) {
//     return VideoComment(
//       id: json['id'] as int,
//       videoId: json['video_id'] as int,
//       userId: json['user_id'] as int,
//       content: json['content'] as String,
//       parentId: json['parent_id'],
//       likeCount: json['like_count'] as int,
//       createdAt: DateTime.parse(json['created_at']),
//       childCount: json['child_count'] as int? ?? 0,
//       isLike: json['is_like'] as bool? ?? false,
//       commentUser: json['comment_user'] != null
//           ? SimpleUser.fromJson(json['comment_user'])
//           : null,
//       commentToUser: json['comment_to_user'] != null
//           ? SimpleUser.fromJson(json['comment_to_user'])
//           : null,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'video_id': videoId,
//       'user_id': userId,
//       'content': content,
//       'parent_id': parentId,
//       'like_count': likeCount,
//       'created_at': createdAt.toIso8601String(),
//       'child_count': childCount,
//       'is_like': isLike,
//       'comment_user': commentUser?.toJson(),
//       'comment_to_user': commentToUser?.toJson(),
//     };
//   }
// }