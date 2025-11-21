// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simple_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SimpleUser _$SimpleUserFromJson(Map<String, dynamic> json) => SimpleUser(
  id: parseInt(json['id']),
  nickname: json['nickname'] as String,
  avatar: json['avatar'] as String,
  bio: json['bio'] as String,
  isFollowed: json['isFollowed'] == null
      ? false
      : parseBool(json['isFollowed']),
);

Map<String, dynamic> _$SimpleUserToJson(SimpleUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nickname': instance.nickname,
      'avatar': instance.avatar,
      'isFollowed': instance.isFollowed,
      'bio': instance.bio,
    };
