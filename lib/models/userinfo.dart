import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/utils/json_utils.dart';
import 'agent.dart';

part 'userinfo.g.dart';

@JsonSerializable(explicitToJson: true)
class UserInfo {
  @JsonKey(fromJson: parseInt)
  final int id;
  @JsonKey(name: 'display_id', fromJson: parseInt)
  final int displayId;
  final String? username;
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

  UserInfo({
    required this.id,
    required this.displayId,
    this.username,
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
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) =>
      _$UserInfoFromJson(json);

  Map<String, dynamic> toJson() => _$UserInfoToJson(this);

  UserInfo copyWith({
    int? id,
    int? displayId,
    String? username,
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
  }) {
    return UserInfo(
      id: id ?? this.id,
      displayId: displayId ?? this.displayId,
      username: username ?? this.username,
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
    );
  }
}


// import 'agent.dart';
//
// class UserInfo {
//   final int id;
//   final int displayId;
//   final String? username;
//   final String credential;
//   final bool isVisitor;
//   final bool isBindPass;
//   final int agentId;
//   final Agent agent;
//   final String inviteCode;
//   final int level;
//   final int nextExp;
//   final String levelName;
//
//   // final DateTime createdAt;
//   final String? token;
//   final String? avatar;
//   final String? phone;
//   final String? bio;
//   final String? cover;
//   final String nickname;
//   final int? fansCount;
//   final int? followCount;
//   final int? likeCount;
//
//   /// 新增字段：是否关注，默认 false
//   final bool isFollowed;
//
//   UserInfo({
//     required this.id,
//     required this.displayId,
//     required this.username,
//     required this.credential,
//     required this.isVisitor,
//     required this.isBindPass,
//     required this.agentId,
//     required this.agent,
//     required this.inviteCode,
//     required this.level,
//     required this.nextExp,
//     required this.levelName,
//     this.avatar,
//     this.phone,
//     this.bio,
//     this.cover,
//     required this.nickname,
//     this.token,
//     this.fansCount,
//     this.followCount,
//     this.likeCount,
//     this.isFollowed = false, // 默认值 false
//   });
//
//   factory UserInfo.fromJson(Map<String, dynamic> json) {
//     return UserInfo(
//       id: json['id'] ?? 0,
//       displayId: json['display_id'] ?? 0,
//       username: json['username'],
//       credential: json['credential'] ?? '',
//       isVisitor: json['is_visitor'] ?? false,
//       isBindPass: json['is_bind_pass'] ?? false,
//       agentId: json['agent_id'] ?? 0,
//       agent: Agent.fromJson(json['agent'] ?? {}),
//       inviteCode: json['invite_code'] ?? '',
//       level: json['level'] ?? 0,
//       nextExp: json['next_exp'] ?? 0,
//       levelName: json['level_name'] ?? '',
//       token: json['token'],
//       avatar: json['avatar'],
//       phone: json['phone'],
//       bio: json['bio'],
//       cover: json['cover'],
//       nickname: json['nickname'] ?? '',
//       fansCount: json['fans_count'],
//       followCount: json['follow_count'],
//       likeCount: json['like_count'],
//       isFollowed: json['is_followed'] ?? false, // 从 JSON 读取，默认 false
//     );
//   }
//
//   /// JSON 序列化
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'display_id': displayId,
//       'username': username,
//       'credential': credential,
//       'is_visitor': isVisitor,
//       'is_bind_pass': isBindPass,
//       'agent_id': agentId,
//       'agent': agent.toJson(),
//       'invite_code': inviteCode,
//       'level': level,
//       'next_exp': nextExp,
//       'level_name': levelName,
//       'token': token,
//       'avatar': avatar,
//       'phone': phone,
//       'bio': bio,
//       'cover': cover,
//       'nickname': nickname,
//       'fans_count': fansCount,
//       'follow_count': followCount,
//       'like_count': likeCount,
//       'is_followed': isFollowed, // 新增字段
//     };
//   }
//
//   /// 拷贝方法，方便更新 isFollowed
//   UserInfo copyWith({
//     int? id,
//     int? displayId,
//     String? username,
//     String? credential,
//     bool? isVisitor,
//     bool? isBindPass,
//     int? agentId,
//     Agent? agent,
//     String? inviteCode,
//     int? level,
//     int? nextExp,
//     String? levelName,
//     String? avatar,
//     String? phone,
//     String? bio,
//     String? cover,
//     String? nickname,
//     String? token,
//     int? fansCount,
//     int? followCount,
//     int? likeCount,
//     bool? isFollowed,
//   }) {
//     return UserInfo(
//       id: id ?? this.id,
//       displayId: displayId ?? this.displayId,
//       username: username ?? this.username,
//       credential: credential ?? this.credential,
//       isVisitor: isVisitor ?? this.isVisitor,
//       isBindPass: isBindPass ?? this.isBindPass,
//       agentId: agentId ?? this.agentId,
//       agent: agent ?? this.agent,
//       inviteCode: inviteCode ?? this.inviteCode,
//       level: level ?? this.level,
//       nextExp: nextExp ?? this.nextExp,
//       levelName: levelName ?? this.levelName,
//       avatar: avatar ?? this.avatar,
//       phone: phone ?? this.phone,
//       bio: bio ?? this.bio,
//       cover: cover ?? this.cover,
//       nickname: nickname ?? this.nickname,
//       token: token ?? this.token,
//       fansCount: fansCount ?? this.fansCount,
//       followCount: followCount ?? this.followCount,
//       likeCount: likeCount ?? this.likeCount,
//       isFollowed: isFollowed ?? this.isFollowed,
//     );
//   }
// }