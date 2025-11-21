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


// class Agent {
//   final int id;
//   final int displayId;
//   final String username;
//   final String role;
//   final String code;
//   final int parentId;
//   final DateTime createdAt;
//   // final DateTime updatedAt;
//   // final DateTime? deletedAt;
//
//   Agent({
//     required this.id,
//     required this.displayId,
//     required this.username,
//     required this.role,
//     required this.code,
//     required this.parentId,
//     required this.createdAt,
//     // required this.updatedAt,
//     // this.deletedAt,
//   });
//
//   factory Agent.fromJson(Map<String, dynamic> json) {
//     return Agent(
//       id: json['id'] ?? 0,
//       displayId: json['display_id'] ?? 0,
//       username: json['username'] ?? '',
//       role: json['role'] ?? '',
//       code: json['code'] ?? '',
//       parentId: json['parent_id'] ?? 0,
//       createdAt: DateTime.parse(json['created_at']),
//       // updatedAt: DateTime.parse(json['updated_at']),
//       // deletedAt: json['deleted_at'] != null ? DateTime.tryParse(json['deleted_at']) : null,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'display_id': displayId,
//       'username': username,
//       'role': role,
//       'code': code,
//       'parent_id': parentId,
//       'created_at': createdAt.toIso8601String(),
//       // 'updated_at': updatedAt.toIso8601String(),
//       // 'deleted_at': deletedAt?.toIso8601String(),
//     };
//   }
// }
