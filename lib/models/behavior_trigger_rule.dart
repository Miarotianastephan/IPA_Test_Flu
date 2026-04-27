import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/utils/json_utils.dart';

part 'behavior_trigger_rule.g.dart';

enum BehaviorEventType {
  @JsonValue('browse_count')
  browseCount,
  @JsonValue('watch_count')
  watchCount,
  @JsonValue('stay_duration')
  stayDuration,
  @JsonValue('like_count')
  likeCount,
  @JsonValue('comment_count')
  commentCount,
  @JsonValue('share_count')
  shareCount,
  @JsonValue('page_visit_count')
  pageVisitCount,
  @JsonValue('ai_chat_count')
  aiChatCount,
  @JsonValue('custom_combination')
  customCombination,
  @JsonValue('loading_complete')
  loadingComplete,
}

enum RuleComparator {
  @JsonValue('>=')
  greaterOrEqual,
  @JsonValue('>')
  greater,
  @JsonValue('<=')
  lessOrEqual,
  @JsonValue('<')
  less,
  @JsonValue('=')
  equal,
}

enum RuleOperator {
  @JsonValue('AND')
  and,
  @JsonValue('OR')
  or,
}

@JsonSerializable()
class RuleCondition {
  @JsonKey(name: 'type')
  final BehaviorEventType eventType;

  @JsonKey(name: 'comparator')
  final RuleComparator comparator;

  @JsonKey(fromJson: parseInt)
  final int threshold;

  RuleCondition({
    required this.eventType,
    required this.comparator,
    required this.threshold,
  });

  factory RuleCondition.fromJson(Map<String, dynamic> json) =>
      _$RuleConditionFromJson(json);

  Map<String, dynamic> toJson() => _$RuleConditionToJson(this);

  bool isSatisfied(int currentValue) {
    switch (comparator) {
      case RuleComparator.greaterOrEqual:
        return currentValue >= threshold;
      case RuleComparator.greater:
        return currentValue > threshold;
      case RuleComparator.lessOrEqual:
        return currentValue <= threshold;
      case RuleComparator.less:
        return currentValue < threshold;
      case RuleComparator.equal:
        return currentValue == threshold;
    }
  }
}

@JsonSerializable()
class BehaviorTriggerRule {
  @JsonKey(fromJson: parseInt)
  final int id;

  @JsonKey(name: 'rule_code')
  final String ruleCode;

  @JsonKey(name: 'rule_name')
  final String ruleName;

  @JsonKey(name: 'rule_description')
  final String? ruleDescription;

  final List<RuleCondition> conditions;

  @JsonKey(name: 'operator')
  final RuleOperator? operator;

  @JsonKey(fromJson: parseBool, defaultValue: true)
  final bool enabled;

  @JsonKey(fromJson: parseInt, defaultValue: 0)
  final int priority;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  BehaviorTriggerRule({
    required this.id,
    required this.ruleCode,
    required this.ruleName,
    this.ruleDescription,
    required this.conditions,
    this.operator,
    this.enabled = true,
    this.priority = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory BehaviorTriggerRule.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('triggerType') && json.containsKey('thresholdValue')) {
      return BehaviorTriggerRule._fromBackendFormat(json);
    }
    return _$BehaviorTriggerRuleFromJson(json);
  }

  static BehaviorTriggerRule _fromBackendFormat(Map<String, dynamic> json) {
    final List<RuleCondition> conditions = [];
    RuleOperator? operator;

    if (json['combinationRules'] != null && json['combinationRules'] is Map) {
      final combinationRules = json['combinationRules'] as Map<String, dynamic>;

      final operatorStr = combinationRules['operator'] as String?;
      if (operatorStr != null) {
        operator = operatorStr.toUpperCase() == 'AND'
            ? RuleOperator.and
            : RuleOperator.or;
      }

      final parentComparatorStr = json['comparator'] as String?;
      final parentComparator = parentComparatorStr != null
          ? _parseComparator(parentComparatorStr)
          : RuleComparator.greaterOrEqual;

      if (combinationRules['conditions'] is List) {
        final conditionsList = combinationRules['conditions'] as List;
        for (final condItem in conditionsList) {
          if (condItem is Map<String, dynamic>) {
            final typeStr = condItem['type'] as String?;
            if (typeStr == null) continue;

            final eventType = _parseEventType(typeStr);
            if (eventType == null) continue;

            final comparatorStr = condItem['comparator'] as String?;
            final comparator = comparatorStr != null
                ? _parseComparator(comparatorStr)
                : parentComparator;

            if (comparator == null) continue;

            final threshold = parseInt(condItem['threshold']);

            conditions.add(
              RuleCondition(
                eventType: eventType,
                comparator: comparator,
                threshold: threshold,
              ),
            );
          }
        }
      }
    } else {
      final typeStr = json['triggerType'] as String?;
      if (typeStr != null) {
        final eventType = _parseEventType(typeStr);
        if (eventType != null) {
          final comparatorStr = json['comparator'] as String?;
          final comparator = comparatorStr != null
              ? _parseComparator(comparatorStr)
              : RuleComparator.greaterOrEqual;

          final threshold = parseInt(json['thresholdValue']);

          conditions.add(
            RuleCondition(
              eventType: eventType,
              comparator: comparator ?? RuleComparator.greaterOrEqual,
              threshold: threshold,
            ),
          );
        }
      }
    }

    return BehaviorTriggerRule(
      id: parseInt(json['id']),
      ruleCode:
          json['ruleCode'] as String? ?? json['rule_code'] as String? ?? '',
      ruleName:
          json['ruleName'] as String? ?? json['rule_name'] as String? ?? '',
      ruleDescription:
          json['ruleDescription'] as String? ??
          json['rule_description'] as String?,
      conditions: conditions,
      operator: operator,
      enabled: json['enabled'] != null ? parseBool(json['enabled']) : true,
      priority: json['priority'] != null ? parseInt(json['priority']) : 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  static BehaviorEventType? _parseEventType(String type) {
    switch (type) {
      case 'loading_complete':
        return BehaviorEventType.loadingComplete;
      case 'browse_count':
        return BehaviorEventType.browseCount;
      case 'watch_count':
        return BehaviorEventType.watchCount;
      case 'stay_duration':
        return BehaviorEventType.stayDuration;
      case 'like_count':
        return BehaviorEventType.likeCount;
      case 'comment_count':
        return BehaviorEventType.commentCount;
      case 'share_count':
        return BehaviorEventType.shareCount;
      case 'page_visit_count':
        return BehaviorEventType.pageVisitCount;
      case 'ai_chat_count':
        return BehaviorEventType.aiChatCount;
      case 'custom_combination':
        return BehaviorEventType.customCombination;
      default:
        return null;
    }
  }

  static RuleComparator? _parseComparator(String comparator) {
    switch (comparator) {
      case '>=':
        return RuleComparator.greaterOrEqual;
      case '>':
        return RuleComparator.greater;
      case '<=':
        return RuleComparator.lessOrEqual;
      case '<':
        return RuleComparator.less;
      case '=':
      case '==':
        return RuleComparator.equal;
      default:
        return null;
    }
  }

  Map<String, dynamic> toJson() => _$BehaviorTriggerRuleToJson(this);

  bool isSatisfied(Map<BehaviorEventType, int> userStats) {
    if (conditions.isEmpty) return false;

    if (conditions.length == 1) {
      final condition = conditions.first;
      final currentValue = userStats[condition.eventType] ?? 0;
      return condition.isSatisfied(currentValue);
    }

    final results = conditions.map((condition) {
      final currentValue = userStats[condition.eventType] ?? 0;
      return condition.isSatisfied(currentValue);
    }).toList();

    if (operator == RuleOperator.and) {
      return results.every((result) => result);
    } else if (operator == RuleOperator.or) {
      return results.any((result) => result);
    }

    return false;
  }
}
