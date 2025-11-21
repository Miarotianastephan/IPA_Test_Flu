import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/utils/json_utils.dart';
import 'userinfo.dart';
import 'video_category.dart';
import 'video_tag.dart';

part 'video_info.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class VideoInfo {
  @JsonKey(fromJson: parseInt)
  final int id;
  @JsonKey(name: 'user_id', fromJson: parseInt)
  final int userId;
  final String title;
  final String description;
  final int type;
  final int duration;
  final String url;
  final String cover;
  @JsonKey(fromJson: parseDouble)
  final double price;
  final String province;
  final String city;
  final UserInfo user;
  @JsonKey(defaultValue : 0,fromJson:  parseInt)
  final int commentCount;
  @JsonKey(defaultValue: false, fromJson: parseBool)
  final bool isFollow;
  @JsonKey(defaultValue: false, fromJson: parseBool)
  final bool isLike;
  @JsonKey(defaultValue: false, fromJson: parseBool)
  final bool isFavorite;
  @JsonKey(defaultValue: 0)
  final int likeCount;
  @JsonKey(defaultValue: 0)
  final int favoriteCount;
  @JsonKey(defaultValue: 0)
  final int viewCount;
  @JsonKey(defaultValue: false, fromJson: parseBool)
  final bool needVip;
  @JsonKey(defaultValue: [])
  final List<VideoTag> tags;
  @JsonKey(defaultValue: [])
  final List<VideoCategory> categories;
  final DateTime createdAt;

  VideoInfo({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.type,
    required this.duration,
    required this.url,
    required this.cover,
    required this.price,
    required this.province,
    required this.city,
    required this.user,
    this.commentCount = 0,
    this.isFollow = false,
    this.isLike = false,
    this.isFavorite = false,
    this.likeCount = 0,
    this.favoriteCount = 0,
    this.viewCount = 0,
    this.needVip = false,
    this.tags = const [],
    this.categories = const [],
    required this.createdAt,
  });

  factory VideoInfo.fromJson(Map<String, dynamic> json) =>
      _$VideoInfoFromJson(json);

  Map<String, dynamic> toJson() => _$VideoInfoToJson(this);

  VideoInfo copyWith({
    bool? isFollow,
    bool? isLike,
    bool? isFavorite,
    int? likeCount,
    int? favoriteCount,
    int? commentCount,
    int? viewCount,
    bool? needVip,
    List<VideoTag>? tags,
    List<VideoCategory>? categories,
    DateTime? createdAt,
    UserInfo? user,
  }) {
    return VideoInfo(
      id: id,
      userId: userId,
      title: title,
      description: description,
      type: type,
      duration: duration,
      url: url,
      cover: cover,
      price: price,
      province: province,
      city: city,
      user: user ?? this.user,
      commentCount: commentCount ?? this.commentCount,
      isFollow: isFollow ?? this.isFollow,
      isLike: isLike ?? this.isLike,
      isFavorite: isFavorite ?? this.isFavorite,
      likeCount: likeCount ?? this.likeCount,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      viewCount: viewCount ?? this.viewCount,
      needVip: needVip ?? this.needVip,
      tags: tags ?? this.tags,
      categories: categories ?? this.categories,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// import 'userinfo.dart';
// import 'video_category.dart';
// import 'video_tag.dart';
//
// class VideoInfo {
//   final int id;
//   final int userId;
//   final String title;
//   final String description;
//   final int type;
//   final int duration;
//   final String url;
//   final String cover;
//   final double price;
//   final String province;
//   final String city;
//   final UserInfo user;
//   final int commentCount;
//   final bool isFollow;
//   final bool isLike;
//   final bool isFavorite; // 收藏状态
//   final int likeCount; // 点赞数
//   final int favoriteCount; // 收藏数
//   final int viewCount;   //观看数
//   final bool needVip; // 是否需要VIP
//   final List<VideoTag> tags; // 标签列表
//   final List<VideoCategory> categories; // 分类列表
//   final DateTime createdAt; // 创建时间
//
//   VideoInfo({
//     required this.id,
//     required this.userId,
//     required this.title,
//     required this.description,
//     required this.type,
//     required this.duration,
//     required this.url,
//     required this.cover,
//     required this.price,
//     required this.province,
//     required this.city,
//     required this.user,
//     required this.commentCount,
//     required this.isFollow,
//     required this.isLike,
//     required this.isFavorite,
//     required this.likeCount,
//     required this.favoriteCount,
//     required this.needVip,
//     required this.tags,
//     required this.categories,
//     required this.viewCount,
//     required this.createdAt,
//   });
//
//   factory VideoInfo.fromJson(Map<String, dynamic> json) {
//     return VideoInfo(
//       id: json['id'] as int,
//       userId: json['user_id'] as int,
//       title: json['title'] as String,
//       description: json['description'] as String,
//       type: json['type'] as int,
//       duration: json['duration'] as int,
//       url: json['url'] as String,
//       cover: json['cover'] as String,
//       price: (json['price'] as num).toDouble(),
//       province: json['province'] as String,
//       city: json['city'] as String,
//       user: UserInfo.fromJson(json['user']),
//       commentCount: json['comment_count'] as int,
//       isFollow: json['is_follow'] as bool,
//       isLike: json['is_like'] as bool,
//       isFavorite: json['is_favorite'] as bool,
//       likeCount: json['like_count'] as int,
//       favoriteCount: json['favorite_count'] as int,
//       needVip: json['need_vip'] as bool? ?? false,
//       tags: (json['tags'] as List<dynamic>? ?? [])
//           .map((e) => VideoTag.fromJson(e as Map<String, dynamic>))
//           .toList(),
//       categories: (json['categories'] as List<dynamic>? ?? [])
//           .map((e) => VideoCategory.fromJson(e as Map<String, dynamic>))
//           .toList(),
//       viewCount: json['view_count'] as int? ?? 0,
//       createdAt: DateTime.parse(json['created_at'] as String),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'user_id': userId,
//       'title': title,
//       'description': description,
//       'type': type,
//       'duration': duration,
//       'url': url,
//       'cover': cover,
//       'price': price,
//       'province': province,
//       'city': city,
//       'user': user.toJson(),
//       'comment_count': commentCount,
//       'is_follow': isFollow,
//       'is_like': isLike,
//       'is_favorite': isFavorite,
//       'like_count': likeCount,
//       'favorite_count': favoriteCount,
//       'need_vip': needVip,
//       'tags': tags.map((e) => e.toJson()).toList(),
//       'categories': categories.map((e) => e.toJson()).toList(),
//       'view_count': viewCount,
//       'created_at': createdAt.toIso8601String(),
//     };
//   }
//
//   VideoInfo copyWith({
//     bool? isFollow,
//     bool? isLike,
//     bool? isFavorite,
//     int? likeCount,
//     int? favoriteCount,
//     int? commentCount,
//     int? viewCount,
//     bool? needVip,
//     List<VideoTag>? tags,
//     List<VideoCategory>? categories,
//     DateTime? createdAt,
//   }) {
//     return VideoInfo(
//       id: id,
//       userId: userId,
//       title: title,
//       description: description,
//       type: type,
//       duration: duration,
//       url: url,
//       cover: cover,
//       price: price,
//       province: province,
//       city: city,
//       user: user,
//       commentCount: commentCount ?? this.commentCount,
//       isFollow: isFollow ?? this.isFollow,
//       isLike: isLike ?? this.isLike,
//       isFavorite: isFavorite ?? this.isFavorite,
//       likeCount: likeCount ?? this.likeCount,
//       favoriteCount: favoriteCount ?? this.favoriteCount,
//       needVip: needVip ?? this.needVip,
//       tags: tags ?? this.tags,
//       categories: categories ?? this.categories,
//       viewCount: viewCount ?? this.viewCount,
//       createdAt: createdAt ?? this.createdAt
//     );
//   }
// }
