import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

import '../utils/json_utils.dart';
import 'conversation_user.dart';
import 'message.dart';

part 'conversation.g.dart';

@JsonSerializable(explicitToJson: true)
class Conversation {
  @JsonKey(fromJson: parseInt)
  final int id;

  final String? name;

  /// single / group
  final String type;

  @JsonKey(name: 'last_message_id', fromJson: parseInt)
  final int? lastMessageId;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  /// 新增：未读数量，对应后端的 unread_count
  @JsonKey(name: 'unread_count', defaultValue: 0)
  final int unreadCount;

  /// 会话成员
  final List<ConversationUser> users;

  /// 最后一条消息
  @JsonKey(name: 'last_message')
  final Message? lastMessage;

  Conversation({
    required this.id,
    this.name,
    required this.type,
    this.lastMessageId,
    required this.createdAt,
    required this.updatedAt,
    this.unreadCount = 0,
    this.users = const [],
    this.lastMessage,
  });

  Conversation copyWith({
    int? id,
    String? name,
    String? type,
    int? lastMessageId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? unreadCount,
    List<ConversationUser>? users,
    Message? lastMessage,
  }) {
    return Conversation(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      unreadCount: unreadCount ?? this.unreadCount,
      users: users ?? this.users,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationToJson(this);
}

extension ConversationJsonString on Conversation {
  String toJsonString() => jsonEncode(toJson());
}

class ConversationJsonParse {
  static Conversation fromJsonString(String jsonStr) {
    return Conversation.fromJson(jsonDecode(jsonStr));
  }
}
