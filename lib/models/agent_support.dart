import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/utils/json_utils.dart';

part 'agent_support.g.dart';

@JsonSerializable()
class AgentSupport {
  final String id;
  final String? username;
  @JsonKey(name: 'loginId')
  final String? loginId;
  final String? password;
  @JsonKey(name: 'password_retrait')
  final String? passwordRetrait;
  final String? role;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @JsonKey(name: 'deleted_at')
  final DateTime? deletedAt;
  final String? code;
  @JsonKey(name: 'parent_id')
  final String? parentId;
  @JsonKey(name: 'is_active', fromJson: parseBool)
  final bool isActive;
  @JsonKey(fromJson: parseDouble)
  final double revenue;
  @JsonKey(name: 'commission_rate', fromJson: parseInt)
  final int commissionRate;
  @JsonKey(name: 'estimated_revenue', fromJson: parseDouble)
  final double estimatedRevenue;
  @JsonKey(name: 'withdrawable_amount', fromJson: parseDouble)
  final double withdrawableAmount;
  @JsonKey(name: 'withdrawing_amount', fromJson: parseDouble)
  final double withdrawingAmount;
  @JsonKey(name: 'withdrawn_amount', fromJson: parseDouble)
  final double withdrawnAmount;
  final String? avatar;

  AgentSupport({
    required this.id,
    this.username,
    this.loginId,
    this.password,
    this.passwordRetrait,
    this.role,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.code,
    this.parentId,
    this.isActive = false,
    this.revenue = 0.0,
    this.commissionRate = 0,
    this.estimatedRevenue = 0.0,
    this.withdrawableAmount = 0.0,
    this.withdrawingAmount = 0.0,
    this.withdrawnAmount = 0.0,
    this.avatar,
  });

  factory AgentSupport.fromJson(Map<String, dynamic> json) =>
      _$AgentSupportFromJson(json);

  Map<String, dynamic> toJson() => _$AgentSupportToJson(this);
}
