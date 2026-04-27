// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'userinfo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserInfo _$UserInfoFromJson(Map<String, dynamic> json) => UserInfo(
  id: json['id'] as String,
  displayId: json['display_id'] as String,
  username: json['username'] as String?,
  password: json['password'] as String?,
  credential: json['credential'] as String?,
  isVisitor: parseBool(json['is_visitor']),
  isBindPass: parseBool(json['is_bind_pass']),
  agentId: parseInt(json['agent_id']),
  agent: json['agent'] == null
      ? null
      : Agent.fromJson(json['agent'] as Map<String, dynamic>),
  inviteCode: json['invite_code'] as String?,
  level: (json['level'] as num?)?.toInt(),
  nextExp: (json['next_exp'] as num?)?.toInt(),
  levelName: json['level_name'] as String?,
  token: json['token'] as String?,
  avatar: json['avatar'] as String?,
  phone: json['phone'] as String?,
  bio: json['bio'] as String?,
  cover: json['cover'] as String?,
  nickname: json['nickname'] as String?,
  fansCount: (json['fans_count'] as num?)?.toInt(),
  followCount: (json['follow_count'] as num?)?.toInt(),
  likeCount: (json['like_count'] as num?)?.toInt(),
  isFollowed: json['is_followed'] == null
      ? false
      : parseBool(json['is_followed']),
  isBot: json['is_bot'] == null ? false : parseBool(json['is_bot']),
  vipId: parseInt(json['vip_id']),
  vip: json['vip'] == null
      ? null
      : Vip.fromJson(json['vip'] as Map<String, dynamic>),
  lastDailyWatchDate: json['last_daily_watch_date'] == null
      ? null
      : DateTime.parse(json['last_daily_watch_date'] as String),
  dailyWatchTimeLeft: json['daily_watch_time_left'] == null
      ? 300
      : parseInt(json['daily_watch_time_left']),
  extraWatchTimeLeft: json['extra_watch_time_left'] == null
      ? 0
      : parseInt(json['extra_watch_time_left']),
);

Map<String, dynamic> _$UserInfoToJson(UserInfo instance) => <String, dynamic>{
  'id': instance.id,
  'display_id': instance.displayId,
  'username': instance.username,
  'password': instance.password,
  'credential': instance.credential,
  'is_visitor': instance.isVisitor,
  'is_bind_pass': instance.isBindPass,
  'agent_id': instance.agentId,
  'agent': instance.agent?.toJson(),
  'invite_code': instance.inviteCode,
  'level': instance.level,
  'next_exp': instance.nextExp,
  'level_name': instance.levelName,
  'token': instance.token,
  'avatar': instance.avatar,
  'phone': instance.phone,
  'bio': instance.bio,
  'cover': instance.cover,
  'nickname': instance.nickname,
  'fans_count': instance.fansCount,
  'follow_count': instance.followCount,
  'like_count': instance.likeCount,
  'is_followed': instance.isFollowed,
  'is_bot': instance.isBot,
  'vip_id': instance.vipId,
  'vip': instance.vip?.toJson(),
  'daily_watch_time_left': instance.dailyWatchTimeLeft,
  'extra_watch_time_left': instance.extraWatchTimeLeft,
  'last_daily_watch_date': instance.lastDailyWatchDate?.toIso8601String(),
};
