// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campaign.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Campaign _$CampaignFromJson(Map<String, dynamic> json) => Campaign(
  id: parseInt(json['id']),
  campaignCode: json['campaign_code'] as String,
  name: json['name'] as String,
  status: json['status'] as String,
  startTime: json['start_time'] as String,
  endTime: json['end_time'] as String,
  audienceType: json['audience_type'] as String,
  campaignPageUrl: json['campaign_page_url'] as String?,
  banner: json['banner'] as String?,
  cover: json['cover'] as String?,
  pageConfig: PageConfig.fromJson(json['page_config'] as Map<String, dynamic>),
  ruleType: json['rule_type'] as String,
  ruleConfig: json['rule_config'] == null
      ? null
      : RuleConfig.fromJson(json['rule_config'] as Map<String, dynamic>),
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
  campaignTier: (json['campaign_tier'] as List<dynamic>)
      .map((e) => CampaignTier.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CampaignToJson(Campaign instance) => <String, dynamic>{
  'id': instance.id,
  'campaign_code': instance.campaignCode,
  'name': instance.name,
  'status': instance.status,
  'start_time': instance.startTime,
  'end_time': instance.endTime,
  'audience_type': instance.audienceType,
  'campaign_page_url': instance.campaignPageUrl,
  'banner': instance.banner,
  'cover': instance.cover,
  'page_config': instance.pageConfig,
  'rule_type': instance.ruleType,
  'rule_config': instance.ruleConfig,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'campaign_tier': instance.campaignTier,
};

PageConfig _$PageConfigFromJson(Map<String, dynamic> json) => PageConfig(
  buttonText: json['buttonText'] as String,
  themeColor: json['themeColor'] as String,
  showCountdown: json['showCountdown'] as bool,
);

Map<String, dynamic> _$PageConfigToJson(PageConfig instance) =>
    <String, dynamic>{
      'buttonText': instance.buttonText,
      'themeColor': instance.themeColor,
      'showCountdown': instance.showCountdown,
    };

RuleConfig _$RuleConfigFromJson(Map<String, dynamic> json) => RuleConfig(
  currency: json['currency'] as String?,
  countOnlySuccessPayment: json['count_only_success_payment'] as bool?,
);

Map<String, dynamic> _$RuleConfigToJson(RuleConfig instance) =>
    <String, dynamic>{
      'currency': instance.currency,
      'count_only_success_payment': instance.countOnlySuccessPayment,
    };

Tier _$TierFromJson(Map<String, dynamic> json) => Tier(
  amount: (json['amount'] as num).toDouble(),
  rewardType: json['reward_type'] as String,
  rewardValue: (json['reward_value'] as num).toDouble(),
);

Map<String, dynamic> _$TierToJson(Tier instance) => <String, dynamic>{
  'amount': instance.amount,
  'reward_type': instance.rewardType,
  'reward_value': instance.rewardValue,
};

CampaignTier _$CampaignTierFromJson(Map<String, dynamic> json) => CampaignTier(
  id: parseInt(json['id']),
  campaignId: (json['campaign_id'] as num).toInt(),
  tierCode: json['tier_code'] as String,
  thresholdAmount: json['threshold_amount'] as String,
  grantMode: json['grant_mode'] as String,
  sortOrder: (json['sort_order'] as num).toInt(),
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
);

Map<String, dynamic> _$CampaignTierToJson(CampaignTier instance) =>
    <String, dynamic>{
      'id': instance.id,
      'campaign_id': instance.campaignId,
      'tier_code': instance.tierCode,
      'threshold_amount': instance.thresholdAmount,
      'grant_mode': instance.grantMode,
      'sort_order': instance.sortOrder,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
