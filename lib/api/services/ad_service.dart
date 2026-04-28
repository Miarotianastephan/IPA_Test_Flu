import 'package:live_app/api/ad_api.dart';
import 'package:live_app/api/services/base_service.dart';
import 'package:live_app/models/ad.dart';
import 'package:live_app/models/api_response.dart';
import 'package:live_app/models/behavior_trigger_rule.dart';
import 'package:live_app/models/page_params.dart';
import 'package:live_app/models/page_response.dart';

class AdService extends BaseService {
  AdService(super.client);

  Future<ApiResponse<PageResponse<Ad>>> getAdList({
    String placementCode = "videoFeedInFeed",
    PageParams params = const PageParams(page: 1, limit: 5),
  }) {
    final body = <String, dynamic>{
      "placement_code": placementCode,
      "page": params.page,
      "limit": params.limit,
    };

    return post<PageResponse<Ad>>(
      AdApi.list,
      body: body,
      fromJson: (json) =>
          PageResponse.fromJson(json, (item) => Ad.fromJson(item)),
    );
  }

  Future<ApiResponse<Ad>> getAdDetail(int id) {
    return post<Ad>(
      AdApi.detail,
      body: {"id": id},
      fromJson: (json) => Ad.fromJson(json),
    );
  }

  Future<ApiResponse<List<BehaviorTriggerRule>>> getBehaviorTriggerRules() {
    return post<List<BehaviorTriggerRule>>(
      AdApi.behaviorTriggerRules,
      fromJson: (json) {
        if (json is Map<String, dynamic> && json['list'] is List) {
          final list = json['list'] as List;
          return list
              .map((item) => BehaviorTriggerRule.fromJson(item))
              .toList();
        }
        if (json is List) {
          return json
              .map((item) => BehaviorTriggerRule.fromJson(item))
              .toList();
        }
        return [];
      },
    );
  }

  Future<ApiResponse<Ad>> triggerAdByRule({
    required String ruleCode,
    int? triggerRuleId,
    String? deviceType,
    String? appVersion,
    String? ip,
    String? agentCode,
  }) {
    final body = <String, dynamic>{
      "rule_code": ruleCode,
    };
    if (triggerRuleId != null) body["trigger_rule_id"] = triggerRuleId;
    if (deviceType != null) body["device_type"] = deviceType;
    if (appVersion != null) body["app_version"] = appVersion;
    if (ip != null) body["ip"] = ip;
    if (agentCode != null) body["agent_code"] = agentCode;

    return post<Ad>(
      AdApi.adsByRuleCode,
      body: body,
      fromJson: (json) => Ad.fromJson(json),
    );
  }
}
