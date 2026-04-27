// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simple_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SimpleUser _$SimpleUserFromJson(Map<String, dynamic> json) => SimpleUser(
  id: json['id'] as String,
  nickname: json['nickname'] as String,
  avatar: json['avatar'] as String? ?? '',
  bio: json['bio'] as String,
  isFollowed: json['isFollowed'] == null
      ? false
      : parseBool(json['isFollowed']),
  vipId: json['vipId'] as String?,
  vip: json['vip'] == null
      ? null
      : Vip.fromJson(json['vip'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SimpleUserToJson(SimpleUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nickname': instance.nickname,
      'avatar': instance.avatar,
      'isFollowed': instance.isFollowed,
      'bio': instance.bio,
      'vipId': instance.vipId,
      'vip': instance.vip,
    };
