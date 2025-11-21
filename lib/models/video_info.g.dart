// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoInfo _$VideoInfoFromJson(Map<String, dynamic> json) => VideoInfo(
  id: parseInt(json['id']),
  userId: parseInt(json['user_id']),
  title: json['title'] as String,
  description: json['description'] as String,
  type: (json['type'] as num).toInt(),
  duration: (json['duration'] as num).toInt(),
  url: json['url'] as String,
  cover: json['cover'] as String,
  price: parseDouble(json['price']),
  province: json['province'] as String,
  city: json['city'] as String,
  user: UserInfo.fromJson(json['user'] as Map<String, dynamic>),
  commentCount: json['comment_count'] == null
      ? 0
      : parseInt(json['comment_count']),
  isFollow: json['is_follow'] == null ? false : parseBool(json['is_follow']),
  isLike: json['is_like'] == null ? false : parseBool(json['is_like']),
  isFavorite: json['is_favorite'] == null
      ? false
      : parseBool(json['is_favorite']),
  likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
  favoriteCount: (json['favorite_count'] as num?)?.toInt() ?? 0,
  viewCount: (json['view_count'] as num?)?.toInt() ?? 0,
  needVip: json['need_vip'] == null ? false : parseBool(json['need_vip']),
  tags:
      (json['tags'] as List<dynamic>?)
          ?.map((e) => VideoTag.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  categories:
      (json['categories'] as List<dynamic>?)
          ?.map((e) => VideoCategory.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$VideoInfoToJson(VideoInfo instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'title': instance.title,
  'description': instance.description,
  'type': instance.type,
  'duration': instance.duration,
  'url': instance.url,
  'cover': instance.cover,
  'price': instance.price,
  'province': instance.province,
  'city': instance.city,
  'user': instance.user.toJson(),
  'comment_count': instance.commentCount,
  'is_follow': instance.isFollow,
  'is_like': instance.isLike,
  'is_favorite': instance.isFavorite,
  'like_count': instance.likeCount,
  'favorite_count': instance.favoriteCount,
  'view_count': instance.viewCount,
  'need_vip': instance.needVip,
  'tags': instance.tags.map((e) => e.toJson()).toList(),
  'categories': instance.categories.map((e) => e.toJson()).toList(),
  'created_at': instance.createdAt.toIso8601String(),
};
