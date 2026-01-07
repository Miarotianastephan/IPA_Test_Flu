import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

import '../utils/json_utils.dart';

part 'group.g.dart';

@JsonSerializable(explicitToJson: true)
class Group {
  @JsonKey(fromJson: parseInt)
  final int id;

  final String name;

  final String? description;

  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;

  /// public / private
  final String visibility;

  @JsonKey(name: 'owner_id')
  final String ownerId;

  @JsonKey(name: 'conversation_id', fromJson: parseInt)
  final int conversationId;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Group({
    required this.id,
    required this.name,
    this.description,
    this.avatarUrl,
    required this.visibility,
    required this.ownerId,
    required this.conversationId,
    required this.createdAt,
    required this.updatedAt,
  });

  Group copyWith({
    int? id,
    String? name,
    String? description,
    String? avatarUrl,
    String? visibility,
    String? ownerId,
    int? conversationId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      visibility: visibility ?? this.visibility,
      ownerId: ownerId ?? this.ownerId,
      conversationId: conversationId ?? this.conversationId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);

  Map<String, dynamic> toJson() => _$GroupToJson(this);
}

extension GroupJsonString on Group {
  String toJsonString() => jsonEncode(toJson());
}

class GroupJsonParse {
  static Group fromJsonString(String jsonStr) {
    return Group.fromJson(jsonDecode(jsonStr));
  }
}
