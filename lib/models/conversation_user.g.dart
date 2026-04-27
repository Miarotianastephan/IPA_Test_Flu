// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConversationUser _$ConversationUserFromJson(Map<String, dynamic> json) =>
    ConversationUser(
      id: parseInt(json['id']),
      conversationId: (json['conversation_id'] as num).toInt(),
      userId: json['user_id'] as String?,
      agentSupportId: json['agent_support_id'] as String?,
      role: json['role'] as String? ?? 'member',
      joinedAt: DateTime.parse(json['joined_at'] as String),
      user: json['user'] == null
          ? null
          : UserInfo.fromJson(json['user'] as Map<String, dynamic>),
      agentSupport: json['agent_support'] == null
          ? null
          : AgentSupport.fromJson(
              json['agent_support'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$ConversationUserToJson(ConversationUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'conversation_id': instance.conversationId,
      'user_id': instance.userId,
      'agent_support_id': instance.agentSupportId,
      'role': instance.role,
      'joined_at': instance.joinedAt.toIso8601String(),
      'user': instance.user?.toJson(),
      'agent_support': instance.agentSupport?.toJson(),
    };
