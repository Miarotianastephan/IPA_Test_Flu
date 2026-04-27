import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/models/agent_support.dart';
import 'package:live_app/models/userinfo.dart';

import '../utils/json_utils.dart';

part 'conversation_user.g.dart';

@JsonSerializable(explicitToJson: true)
class ConversationUser {
  @JsonKey(name: "id", fromJson: parseInt)
  final int id;

  @JsonKey(name: "conversation_id")
  final int conversationId;

  @JsonKey(name: "user_id")
  final String? userId;

  @JsonKey(name: "agent_support_id")
  final String? agentSupportId;

  @JsonKey(defaultValue: "member")
  final String role;

  @JsonKey(name: "joined_at")
  final DateTime joinedAt;

  @JsonKey(name: "user")
  final UserInfo? user;

  @JsonKey(name: "agent_support")
  final AgentSupport? agentSupport;

  /// Returns the effective ID for this user (userId or agentSupportId)
  String get effectiveId => userId ?? agentSupportId ?? '';

  /// Whether this conversation user is a support agent
  bool get isSupportAgent => agentSupportId != null && userId == null;

  ConversationUser({
    required this.id,
    required this.conversationId,
    this.userId,
    this.agentSupportId,
    this.role = "member",
    required this.joinedAt,
    this.user,
    this.agentSupport,
  });

  factory ConversationUser.fromJson(Map<String, dynamic> json) =>
      _$ConversationUserFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationUserToJson(this);
}
