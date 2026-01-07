// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_invitation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupInvitation _$GroupInvitationFromJson(Map<String, dynamic> json) =>
    GroupInvitation(
      id: parseInt(json['id']),
      groupId: parseInt(json['group_id']),
      inviterId: json['inviter_id'] as String,
      inviteeId: json['invitee_id'] as String,
      status: json['status'] as String,
      notificationId: parseInt(json['notification_id']),
      expiresAt: DateTime.parse(json['expires_at'] as String),
      respondedAt: json['responded_at'] == null
          ? null
          : DateTime.parse(json['responded_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$GroupInvitationToJson(GroupInvitation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'group_id': instance.groupId,
      'inviter_id': instance.inviterId,
      'invitee_id': instance.inviteeId,
      'status': instance.status,
      'notification_id': instance.notificationId,
      'expires_at': instance.expiresAt.toIso8601String(),
      'responded_at': instance.respondedAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
    };
