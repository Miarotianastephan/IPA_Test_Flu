import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/models/userinfo.dart';
import 'package:live_app/utils/json_utils.dart';
import 'forum_attachment.dart';
import 'forum_category.dart';
import 'simple_user.dart';
import 'forum_tag.dart';

part 'forum_post.g.dart';

@JsonSerializable(explicitToJson: true)
class ForumPost {
  @JsonKey(fromJson: parseInt)
  final int id;
  @JsonKey(name: 'user_id',fromJson: parseInt)
  final int userId;
  @JsonKey(name: 'category_id',fromJson: parseInt)
  final int categoryId;
  final String title;
  final String content;
  @JsonKey(name: 'is_pinned',fromJson: parseBool)
  final bool isPinned;
  @JsonKey(name: 'is_featured',fromJson: parseBool)
  final bool isFeatured;
  final String status;
  @JsonKey(fromJson: parseDouble)
  final double price;
  @JsonKey(name: 'favorite_count')
  final int favoriteCount;
  @JsonKey(name: 'like_count')
  final int likeCount;
  @JsonKey(name: 'dislike_count')
  final int dislikeCount;
  @JsonKey(name: 'view_count')
  final int viewCount;
  @JsonKey(name: 'comment_count')
  final int commentCount;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'deleted_at')
  final DateTime? deletedAt;

  final ForumCategory? category;
  final List<ForumAttachment>? attachments;

  @JsonKey(name: 'is_liked',fromJson: parseBool )
  final bool isLiked;
  @JsonKey(name: 'is_favorited',fromJson: parseBool)
  final bool isFavorited;
  @JsonKey(name: 'is_downvoted',fromJson: parseBool)
  final bool? isDownvoted;

  @JsonKey(name: 'user')
  final UserInfo? user;

  @JsonKey(name: 'tags')
  final List<ForumTag>? tags;

  ForumPost({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.title,
    required this.content,
    required this.isPinned,
    required this.isFeatured,
    required this.status,
    required this.price,
    required this.favoriteCount,
    required this.likeCount,
    required this.dislikeCount,
    required this.viewCount,
    required this.commentCount,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.category,
    this.attachments,
    required this.isLiked,
    required this.isFavorited,
    this.isDownvoted,
    this.user,
    this.tags,
  });

  factory ForumPost.fromJson(Map<String, dynamic> json) =>
      _$ForumPostFromJson(json);

  Map<String, dynamic> toJson() => _$ForumPostToJson(this);



   ForumPost copyWith({
     int? id,
     int? userId,
     int? categoryId,
     String? title,
     String? content,
     bool? isPinned,
     bool? isFeatured,
     String? status,
     double? price,
     int? favoriteCount,
     int? likeCount,
     int? dislikeCount,
     int? viewCount,
     int? commentCount,
     DateTime? createdAt,
     DateTime? updatedAt,
     DateTime? deletedAt,
     ForumCategory? category,
     List<ForumAttachment>? attachments,
     bool? isLiked,
     bool? isFavorited,
     bool? isDownvoted,
     UserInfo? user,
     List<ForumTag>? tags,
   }) {
     return ForumPost(
       id: id ?? this.id,
       userId: userId ?? this.userId,
       categoryId: categoryId ?? this.categoryId,
       title: title ?? this.title,
       content: content ?? this.content,
       isPinned: isPinned ?? this.isPinned,
       isFeatured: isFeatured ?? this.isFeatured,
       status: status ?? this.status,
       price: price ?? this.price,
       favoriteCount: favoriteCount ?? this.favoriteCount,
       likeCount: likeCount ?? this.likeCount,
       dislikeCount: dislikeCount ?? this.dislikeCount,
       viewCount: viewCount ?? this.viewCount,
       commentCount: commentCount ?? this.commentCount,
       createdAt: createdAt ?? this.createdAt,
       updatedAt: updatedAt ?? this.updatedAt,
       deletedAt: deletedAt ?? this.deletedAt,
       category: category ?? this.category,
       attachments: attachments ?? this.attachments,
       isLiked: isLiked ?? this.isLiked,
       isFavorited: isFavorited ?? this.isFavorited,
       isDownvoted: isDownvoted ?? this.isDownvoted,
       user: user ?? this.user,
       tags: tags ?? this.tags,
     );
   }
}