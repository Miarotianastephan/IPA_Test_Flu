import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/models/vip.dart';
import 'package:live_app/utils/json_utils.dart';

import 'agent.dart';

part 'userinfo.g.dart';

@JsonSerializable(explicitToJson: true)
class UserInfo {
  final String id;
  @JsonKey(name: 'display_id')
  final String displayId;
  final String? username;
  @JsonKey(name: 'password')
  final String? password;
  final String? credential;
  @JsonKey(name: 'is_visitor', fromJson: parseBool)
  final bool isVisitor;
  @JsonKey(name: 'is_bind_pass', fromJson: parseBool)
  final bool isBindPass;
  @JsonKey(name: 'agent_id', fromJson: parseInt)
  final int agentId;
  final Agent? agent;
  @JsonKey(name: 'invite_code')
  final String? inviteCode;
  final int? level;
  @JsonKey(name: 'next_exp')
  final int? nextExp;
  @JsonKey(name: 'level_name')
  final String? levelName;
  final String? token;
  final String? avatar;
  final String? phone;
  final String? bio;
  final String? cover;
  final String? nickname;
  @JsonKey(name: 'fans_count')
  final int? fansCount;
  @JsonKey(name: 'follow_count')
  final int? followCount;
  @JsonKey(name: 'like_count')
  final int? likeCount;
  @JsonKey(name: 'is_followed', fromJson: parseBool)
  final bool isFollowed;
  @JsonKey(name: 'is_bot', fromJson: parseBool)
  final bool isBot;
  @JsonKey(name: 'vip_id', fromJson: parseInt)
  final int? vipId;
  final Vip? vip;
  @JsonKey(name: 'daily_watch_time_left', defaultValue: 300, fromJson: parseInt)
  final int? dailyWatchTimeLeft;
  @JsonKey(name: 'extra_watch_time_left', defaultValue: 0, fromJson: parseInt)
  final int? extraWatchTimeLeft;
  @JsonKey(name: 'last_daily_watch_date')
  final DateTime? lastDailyWatchDate;

  UserInfo({
    required this.id,
    required this.displayId,
    this.username,
    this.password,
    required this.credential,
    required this.isVisitor,
    required this.isBindPass,
    required this.agentId,
    this.agent,
    this.inviteCode,
    this.level,
    this.nextExp,
    this.levelName,
    this.token,
    this.avatar,
    this.phone,
    this.bio,
    this.cover,
    required this.nickname,
    this.fansCount,
    this.followCount,
    this.likeCount,
    this.isFollowed = false,
    this.isBot = false,
    this.vipId,
    this.vip,
    this.lastDailyWatchDate,
    this.dailyWatchTimeLeft,
    this.extraWatchTimeLeft,
  });

  /// Creates a minimal placeholder UserInfo (e.g. for support agent display)
  factory UserInfo.placeholder({
    required String id,
    String? nickname,
  }) {
    return UserInfo(
      id: id,
      displayId: '',
      credential: null,
      isVisitor: false,
      isBindPass: false,
      agentId: 0,
      nickname: nickname,
    );
  }

  factory UserInfo.fromJson(Map<String, dynamic> json) =>
      _$UserInfoFromJson(json);

  Map<String, dynamic> toJson() => _$UserInfoToJson(this);

  UserInfo copyWith({
    String? id,
    String? displayId,
    String? username,
    String? password,
    String? credential,
    bool? isVisitor,
    bool? isBindPass,
    int? agentId,
    Agent? agent,
    String? inviteCode,
    int? level,
    int? nextExp,
    String? levelName,
    String? avatar,
    String? phone,
    String? bio,
    String? cover,
    String? nickname,
    String? token,
    int? fansCount,
    int? followCount,
    int? likeCount,
    bool? isFollowed,
    bool? isBot,
    int? vipId,
    Vip? vip,
    DateTime? lastDailyWatchDate,
    int? dailyWatchTimeLeft,
    int? extraWatchTimeLeft,
  }) {
    return UserInfo(
      id: id ?? this.id,
      displayId: displayId ?? this.displayId,
      username: username ?? this.username,
      password: password ?? this.password,
      credential: credential ?? this.credential,
      isVisitor: isVisitor ?? this.isVisitor,
      isBindPass: isBindPass ?? this.isBindPass,
      agentId: agentId ?? this.agentId,
      agent: agent ?? this.agent,
      inviteCode: inviteCode ?? this.inviteCode,
      level: level ?? this.level,
      nextExp: nextExp ?? this.nextExp,
      levelName: levelName ?? this.levelName,
      avatar: avatar ?? this.avatar,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      cover: cover ?? this.cover,
      nickname: nickname ?? this.nickname,
      token: token ?? this.token,
      fansCount: fansCount ?? this.fansCount,
      followCount: followCount ?? this.followCount,
      likeCount: likeCount ?? this.likeCount,
      isFollowed: isFollowed ?? this.isFollowed,
      isBot: isBot ?? this.isBot,
      vipId: vipId ?? this.vipId,
      vip: vip ?? this.vip,
      lastDailyWatchDate: lastDailyWatchDate ?? this.lastDailyWatchDate,
      dailyWatchTimeLeft: dailyWatchTimeLeft ?? this.dailyWatchTimeLeft,
      extraWatchTimeLeft: extraWatchTimeLeft ?? this.extraWatchTimeLeft,
    );
  }
}
