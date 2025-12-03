import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/utils/json_utils.dart';
part 'agent.g.dart';

@JsonSerializable()
class Agent {
  @JsonKey(fromJson: parseInt)
  final int id;
  @JsonKey(name: 'display_id',fromJson: parseInt)
  final int? displayId;
  final String? username;
  final String? role;
  final String? code;
  @JsonKey(name: 'parent_id',fromJson: parseInt)
  final int? parentId;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  // @JsonKey(name: 'updated_at')
  // final DateTime updatedAt;
  // @JsonKey(name: 'deleted_at')
  // final DateTime? deletedAt;

  Agent({
    required this.id,
    required this.displayId,
    required this.username,
    required this.role,
    required this.code,
    this.parentId,
    required this.createdAt,
    // required this.updatedAt,
    // this.deletedAt,
  });

  factory Agent.fromJson(Map<String, dynamic> json) => _$AgentFromJson(json);
  Map<String, dynamic> toJson() => _$AgentToJson(this);
}