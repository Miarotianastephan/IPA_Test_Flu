class AdApi {
  static const String base = "/api/user/ads";

  static const String list = "$base/GetAds";
  static const String detail = "$base/detail";
  static const String behaviorTriggerRules =
      "$base/behavior_trigger_rules/active";
  static const String adsByRuleCode = "$base/rule-code";
}
