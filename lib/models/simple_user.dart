import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/utils/json_utils.dart';

part 'simple_user.g.dart';

@JsonSerializable()
class SimpleUser {
  @JsonKey(fromJson: parseInt)
  final int id;
  final String nickname;
  final String avatar;
  @JsonKey(fromJson: parseBool)
  final bool isFollowed;
  final String bio;

  SimpleUser({
    required this.id,
    required this.nickname,
    required this.avatar,
    required this.bio,
    this.isFollowed = false,
  });

  SimpleUser copyWith({
    int? id,
    String? nickname,
    String? avatar,
    bool? isFollowed,
    String? bio,
  }) {
    return SimpleUser(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      isFollowed: isFollowed ?? this.isFollowed,
    );
  }

  factory SimpleUser.fromJson(Map<String, dynamic> json) =>
      _$SimpleUserFromJson(json);

  Map<String, dynamic> toJson() => _$SimpleUserToJson(this);
}
