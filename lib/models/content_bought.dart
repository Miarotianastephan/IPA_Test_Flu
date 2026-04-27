import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/models/forum_post.dart';
import 'package:live_app/models/video_info.dart';
import 'package:live_app/utils/json_utils.dart';

part 'content_bought.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class ContentBought {
  @JsonKey(fromJson: parseInt)
  final int id;

  @JsonKey(name: 'user_id')
  final String userId;

  final String type;

  @JsonKey(name: 'type_id')
  final String typeId;

  @JsonKey(name: 'bought_at')
  final DateTime boughtAt;

  @JsonKey(fromJson: parseDouble)
  final double price;
  @JsonKey(name: 'video')
  final VideoInfo? video;
  @JsonKey(name: 'post')
  final ForumPost? post;

  ContentBought({
    required this.id,
    required this.userId,
    required this.type,
    required this.typeId,
    required this.boughtAt,
    required this.price,
    this.video,
    this.post,
  });

  factory ContentBought.fromJson(Map<String, dynamic> json) =>
      _$ContentBoughtFromJson(json);

  Map<String, dynamic> toJson() => _$ContentBoughtToJson(this);

  int get typeIdAsInt => int.tryParse(typeId) ?? 0;

  ContentBought copyWith({
    int? id,
    String? userId,
    String? type,
    String? typeId,
    DateTime? boughtAt,
    double? price,
    VideoInfo? video,
    ForumPost? post,
  }) {
    return ContentBought(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      typeId: typeId ?? this.typeId,
      boughtAt: boughtAt ?? this.boughtAt,
      price: price ?? this.price,
      video: video ?? this.video,
      post: post ?? this.post,
    );
  }
}
