import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

import '../utils/json_utils.dart';

part 'group_invitation.g.dart';

@JsonSerializable(explicitToJson: true)
class GroupInvitation {
  @JsonKey(fromJson: parseInt)
  final int id;

  @JsonKey(name: 'group_id', fromJson: parseInt)
  final int groupId;

  @JsonKey(name: 'inviter_id')
  final String inviterId;

  @JsonKey(name: 'invitee_id')
  final String inviteeId;

  /// pending / accepted / rejected
  final String status;

  @JsonKey(name: 'notification_id', fromJson: parseInt)
  final int notificationId;

  @JsonKey(name: 'expires_at')
  final DateTime expiresAt;

  @JsonKey(name: 'responded_at')
  final DateTime? respondedAt;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  GroupInvitation({
    required this.id,
    required this.groupId,
    required this.inviterId,
    required this.inviteeId,
    required this.status,
    required this.notificationId,
    required this.expiresAt,
    this.respondedAt,
    required this.createdAt,
  });

  GroupInvitation copyWith({
    int? id,
    int? groupId,
    String? inviterId,
    String? inviteeId,
    String? status,
    int? notificationId,
    DateTime? expiresAt,
    DateTime? respondedAt,
    DateTime? createdAt,
  }) {
    return GroupInvitation(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      inviterId: inviterId ?? this.inviterId,
      inviteeId: inviteeId ?? this.inviteeId,
      status: status ?? this.status,
      notificationId: notificationId ?? this.notificationId,
      expiresAt: expiresAt ?? this.expiresAt,
      respondedAt: respondedAt ?? this.respondedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory GroupInvitation.fromJson(Map<String, dynamic> json) =>
      _$GroupInvitationFromJson(json);

  Map<String, dynamic> toJson() => _$GroupInvitationToJson(this);
}

extension GroupInvitationJsonString on GroupInvitation {
  String toJsonString() => jsonEncode(toJson());
}

class GroupInvitationJsonParse {
  static GroupInvitation fromJsonString(String jsonStr) {
    return GroupInvitation.fromJson(jsonDecode(jsonStr));
  }
}
