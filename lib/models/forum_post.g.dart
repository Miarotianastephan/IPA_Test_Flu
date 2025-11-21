// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forum_post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ForumPost _$ForumPostFromJson(Map<String, dynamic> json) => ForumPost(
  id: parseInt(json['id']),
  userId: parseInt(json['user_id']),
  categoryId: parseInt(json['category_id']),
  title: json['title'] as String,
  content: json['content'] as String,
  isPinned: parseBool(json['is_pinned']),
  isFeatured: parseBool(json['is_featured']),
  status: json['status'] as String,
  price: parseDouble(json['price']),
  favoriteCount: (json['favorite_count'] as num).toInt(),
  likeCount: (json['like_count'] as num).toInt(),
  dislikeCount: (json['dislike_count'] as num).toInt(),
  viewCount: (json['view_count'] as num).toInt(),
  commentCount: (json['comment_count'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
  category: json['category'] == null
      ? null
      : ForumCategory.fromJson(json['category'] as Map<String, dynamic>),
  attachments: (json['attachments'] as List<dynamic>?)
      ?.map((e) => ForumAttachment.fromJson(e as Map<String, dynamic>))
      .toList(),
  isLiked: parseBool(json['is_liked']),
  isFavorited: parseBool(json['is_favorited']),
  isDownvoted: parseBool(json['is_downvoted']),
  user: json['user'] == null
      ? null
      : UserInfo.fromJson(json['user'] as Map<String, dynamic>),
  tags: (json['tags'] as List<dynamic>?)
      ?.map((e) => ForumTag.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ForumPostToJson(ForumPost instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'category_id': instance.categoryId,
  'title': instance.title,
  'content': instance.content,
  'is_pinned': instance.isPinned,
  'is_featured': instance.isFeatured,
  'status': instance.status,
  'price': instance.price,
  'favorite_count': instance.favoriteCount,
  'like_count': instance.likeCount,
  'dislike_count': instance.dislikeCount,
  'view_count': instance.viewCount,
  'comment_count': instance.commentCount,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
  'category': instance.category?.toJson(),
  'attachments': instance.attachments?.map((e) => e.toJson()).toList(),
  'is_liked': instance.isLiked,
  'is_favorited': instance.isFavorited,
  'is_downvoted': instance.isDownvoted,
  'user': instance.user?.toJson(),
  'tags': instance.tags?.map((e) => e.toJson()).toList(),
};
