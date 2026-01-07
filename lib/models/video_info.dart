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
  @JsonKey(defaultValue: 0, fromJson: parseInt)
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
  @JsonKey(name: 'v_key', defaultValue: 'fsjkey')
  final String? encryptionKey;
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
    this.encryptionKey,
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
    String? encryptionKey,
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
      encryptionKey: encryptionKey ?? this.encryptionKey,
      tags: tags ?? this.tags,
      categories: categories ?? this.categories,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
