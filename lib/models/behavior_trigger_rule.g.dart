// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'behavior_trigger_rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RuleCondition _$RuleConditionFromJson(Map<String, dynamic> json) =>
    RuleCondition(
      eventType: $enumDecode(_$BehaviorEventTypeEnumMap, json['type']),
      comparator: $enumDecode(_$RuleComparatorEnumMap, json['comparator']),
      threshold: parseInt(json['threshold']),
    );

Map<String, dynamic> _$RuleConditionToJson(RuleCondition instance) =>
    <String, dynamic>{
      'type': _$BehaviorEventTypeEnumMap[instance.eventType]!,
      'comparator': _$RuleComparatorEnumMap[instance.comparator]!,
      'threshold': instance.threshold,
    };

const _$BehaviorEventTypeEnumMap = {
  BehaviorEventType.browseCount: 'browse_count',
  BehaviorEventType.watchCount: 'watch_count',
  BehaviorEventType.stayDuration: 'stay_duration',
  BehaviorEventType.likeCount: 'like_count',
  BehaviorEventType.commentCount: 'comment_count',
  BehaviorEventType.shareCount: 'share_count',
  BehaviorEventType.pageVisitCount: 'page_visit_count',
  BehaviorEventType.aiChatCount: 'ai_chat_count',
  BehaviorEventType.customCombination: 'custom_combination',
  BehaviorEventType.loadingComplete: 'loading_complete',
};

const _$RuleComparatorEnumMap = {
  RuleComparator.greaterOrEqual: '>=',
  RuleComparator.greater: '>',
  RuleComparator.lessOrEqual: '<=',
  RuleComparator.less: '<',
  RuleComparator.equal: '=',
};

BehaviorTriggerRule _$BehaviorTriggerRuleFromJson(Map<String, dynamic> json) =>
    BehaviorTriggerRule(
      id: parseInt(json['id']),
      ruleCode: json['rule_code'] as String,
      ruleName: json['rule_name'] as String,
      ruleDescription: json['rule_description'] as String?,
      conditions: (json['conditions'] as List<dynamic>)
          .map((e) => RuleCondition.fromJson(e as Map<String, dynamic>))
          .toList(),
      operator: $enumDecodeNullable(_$RuleOperatorEnumMap, json['operator']),
      enabled: json['enabled'] == null ? true : parseBool(json['enabled']),
      priority: json['priority'] == null ? 0 : parseInt(json['priority']),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$BehaviorTriggerRuleToJson(
  BehaviorTriggerRule instance,
) => <String, dynamic>{
  'id': instance.id,
  'rule_code': instance.ruleCode,
  'rule_name': instance.ruleName,
  'rule_description': instance.ruleDescription,
  'conditions': instance.conditions,
  'operator': _$RuleOperatorEnumMap[instance.operator],
  'enabled': instance.enabled,
  'priority': instance.priority,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};

const _$RuleOperatorEnumMap = {RuleOperator.and: 'AND', RuleOperator.or: 'OR'};
