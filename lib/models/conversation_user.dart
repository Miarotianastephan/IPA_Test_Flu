import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/models/userinfo.dart';

import '../utils/json_utils.dart';

part 'conversation_user.g.dart';

@JsonSerializable(explicitToJson: true)
class ConversationUser {
  @JsonKey(name: "id", fromJson: parseInt)
  final int id;

  @JsonKey(name: "conversation_id")
  final int conversationId;

  @JsonKey(name: "user_id", fromJson: parseInt)
  final int userId;

  @JsonKey(defaultValue: "member")
  final String role;

  @JsonKey(name: "joined_at")
  final DateTime joinedAt;

  @JsonKey(name: "user")
  final UserInfo? user;

  ConversationUser({
    required this.id,
    required this.conversationId,
    required this.userId,
    this.role = "member",
    required this.joinedAt,
    this.user,
  });

  factory ConversationUser.fromJson(Map<String, dynamic> json) =>
      _$ConversationUserFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationUserToJson(this);
}
