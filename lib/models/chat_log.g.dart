// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatLog _$ChatLogFromJson(Map<String, dynamic> json) => ChatLog(
  id: parseInt(json['id']),
  fromUserId: json['fromUserId'] as String,
  toUserId: json['toUserId'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ChatLogToJson(ChatLog instance) => <String, dynamic>{
  'id': instance.id,
  'fromUserId': instance.fromUserId,
  'toUserId': instance.toUserId,
  'createdAt': instance.createdAt.toIso8601String(),
};
