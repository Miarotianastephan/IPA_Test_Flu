import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/utils/json_utils.dart';

part 'user_progress.g.dart';

@JsonSerializable()
class UserProgress {
  @JsonKey(fromJson: parseInt)
  int id;
  @JsonKey(fromJson: parseInt, name: 'campaign_id')
  int campaignId;
  @JsonKey(name: 'user_id')
  String userId;
  @JsonKey(name: 'progress_amount')
  String progressAmount;
  @JsonKey(name: 'first_pay_done')
  bool firstPayDone;
  @JsonKey(name: 'first_pay_order_id')
  String? firstPayOrderId;
  @JsonKey(fromJson: parseInt)
  int version;
  @JsonKey(name: 'updated_at')
  String updatedAt;
  
  UserProgress({
    required this.id,
    required this.campaignId,
    required this.userId,
    required this.progressAmount,
    required this.firstPayDone,
    this.firstPayOrderId,
    required this.version,
    required this.updatedAt,
  });
  
  factory UserProgress.fromJson(Map<String, dynamic> json) => _$UserProgressFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserProgressToJson(this);
}
