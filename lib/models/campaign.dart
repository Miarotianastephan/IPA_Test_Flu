import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/utils/json_utils.dart';

part 'campaign.g.dart';

@JsonSerializable()
class Campaign {
  @JsonKey(fromJson: parseInt)
  int id;
  @JsonKey(name: 'campaign_code')
  String campaignCode;
  String name;
  String status;
  @JsonKey(name: 'start_time')
  String startTime;
  @JsonKey(name: 'end_time')
  String endTime;
  @JsonKey(name: 'audience_type')
  String audienceType;
  @JsonKey(name: 'campaign_page_url')
  String? campaignPageUrl;
  String? banner;
  String? cover;
  @JsonKey(name: 'page_config')
  PageConfig pageConfig;
  @JsonKey(name: 'rule_type')
  String ruleType;
  @JsonKey(name: 'rule_config')
  RuleConfig? ruleConfig;
  @JsonKey(name: 'created_at')
  String createdAt;
  @JsonKey(name: 'updated_at')
  String updatedAt;
  @JsonKey(name: 'campaign_tier')
  List<CampaignTier> campaignTier;
  
  Campaign({
    required this.id,
    required this.campaignCode,
    required this.name,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.audienceType,
    this.campaignPageUrl,
    this.banner,
    this.cover,
    required this.pageConfig,
    required this.ruleType,
    this.ruleConfig,
    required this.createdAt,
    required this.updatedAt,
    required this.campaignTier,
  });
  
  factory Campaign.fromJson(Map<String, dynamic> json) => _$CampaignFromJson(json);
  
  Map<String, dynamic> toJson() => _$CampaignToJson(this);
}

@JsonSerializable()
class PageConfig {
  String buttonText;
  String themeColor;
  bool showCountdown;
  
  PageConfig({
    required this.buttonText,
    required this.themeColor,
    required this.showCountdown,
  });
  
  factory PageConfig.fromJson(Map<String, dynamic> json) => _$PageConfigFromJson(json);
  
  Map<String, dynamic> toJson() => _$PageConfigToJson(this);
}

@JsonSerializable()
class RuleConfig {
  String? currency;
  @JsonKey(name: 'count_only_success_payment')
  bool? countOnlySuccessPayment;
  
  RuleConfig({
    this.currency,
    this.countOnlySuccessPayment,
  });
  
  factory RuleConfig.fromJson(Map<String, dynamic> json) => _$RuleConfigFromJson(json);
  
  Map<String, dynamic> toJson() => _$RuleConfigToJson(this);
}

@JsonSerializable()
class Tier {
  double amount;
  @JsonKey(name: 'reward_type')
  String rewardType;
  @JsonKey(name: 'reward_value')
  double rewardValue;
  
  Tier({
    required this.amount,
    required this.rewardType,
    required this.rewardValue,
  });
  
  factory Tier.fromJson(Map<String, dynamic> json) => _$TierFromJson(json);
  
  Map<String, dynamic> toJson() => _$TierToJson(this);
}

@JsonSerializable()
class CampaignTier {
  @JsonKey(fromJson: parseInt)
  int id;
  @JsonKey(name: 'campaign_id')
  int campaignId;
  @JsonKey(name: 'tier_code')
  String tierCode;
  @JsonKey(name: 'threshold_amount')
  String thresholdAmount;
  @JsonKey(name: 'grant_mode')
  String grantMode;
  @JsonKey(name: 'sort_order')
  int sortOrder;
  @JsonKey(name: 'created_at')
  String createdAt;
  @JsonKey(name: 'updated_at')
  String updatedAt;
  
  CampaignTier({
    required this.id,
    required this.campaignId,
    required this.tierCode,
    required this.thresholdAmount,
    required this.grantMode,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory CampaignTier.fromJson(Map<String, dynamic> json) => _$CampaignTierFromJson(json);
  
  Map<String, dynamic> toJson() => _$CampaignTierToJson(this);
}
