import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/models/vip.dart';
import 'package:live_app/utils/json_utils.dart';

part 'simple_user.g.dart';

@JsonSerializable()
class SimpleUser {
  final String id;
  final String nickname;
  @JsonKey(defaultValue: "")
  final String avatar;
  @JsonKey(fromJson: parseBool)
  final bool isFollowed;
  final String bio;
  final String? vipId;
  final Vip? vip;

  SimpleUser({
    required this.id,
    required this.nickname,
    required this.avatar,
    required this.bio,
    this.isFollowed = false,
    this.vipId,
    this.vip,
  });

  SimpleUser copyWith({
    String? id,
    String? nickname,
    String? avatar,
    bool? isFollowed,
    String? bio,
    String? vipId,
    Vip? vip,
  }) {
    return SimpleUser(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      isFollowed: isFollowed ?? this.isFollowed,
      vipId: vipId ?? this.vipId,
      vip: vip ?? this.vip,
    );
  }

  factory SimpleUser.fromJson(Map<String, dynamic> json) =>
      _$SimpleUserFromJson(json);

  Map<String, dynamic> toJson() => _$SimpleUserToJson(this);
}
