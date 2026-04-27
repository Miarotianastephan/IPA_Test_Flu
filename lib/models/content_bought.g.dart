// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_bought.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContentBought _$ContentBoughtFromJson(Map<String, dynamic> json) =>
    ContentBought(
      id: parseInt(json['id']),
      userId: json['user_id'] as String,
      type: json['type'] as String,
      typeId: json['type_id'] as String,
      boughtAt: DateTime.parse(json['bought_at'] as String),
      price: parseDouble(json['price']),
      video: json['video'] == null
          ? null
          : VideoInfo.fromJson(json['video'] as Map<String, dynamic>),
      post: json['post'] == null
          ? null
          : ForumPost.fromJson(json['post'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ContentBoughtToJson(ContentBought instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'type': instance.type,
      'type_id': instance.typeId,
      'bought_at': instance.boughtAt.toIso8601String(),
      'price': instance.price,
      'video': instance.video?.toJson(),
      'post': instance.post?.toJson(),
    };
