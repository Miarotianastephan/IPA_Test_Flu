import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/ad.dart';
import 'package:live_app/models/behavior_trigger_rule.dart';
import 'package:live_app/models/user_behavior_stats.dart';
import 'package:live_app/provider/api_provider.dart';
import 'package:live_app/provider/my_user_provider.dart';
import 'package:live_app/utils/agent_tracking.dart';
import 'package:live_app/utils/app_package_info.dart';
import 'package:live_app/utils/device_info_helper.dart';

final userBehaviorStatsProvider =
    StateNotifierProvider<UserBehaviorStatsNotifier, UserBehaviorStats>((ref) {
  return UserBehaviorStatsNotifier();
});

class UserBehaviorStatsNotifier extends StateNotifier<UserBehaviorStats> {
  UserBehaviorStatsNotifier() : super(UserBehaviorStats());

  void incrementEvent(BehaviorEventType eventType, {int amount = 1}) {
    // final oldValue = _getEventValue(eventType);
    state.increment(eventType, amount: amount);
    state = state.copyWith();
    // final newValue = _getEventValue(eventType);
  }

  void resetAll() {
    state.reset();
    state = state.copyWith();
  }

  void resetEvent(BehaviorEventType eventType) {
    state.resetEvent(eventType);
    state = state.copyWith();
  }

  int _getEventValue(BehaviorEventType eventType) {
    final map = state.toEventMap();
    return map[eventType] ?? 0;
  }
}

final behaviorTriggerRulesProvider = StateProvider<List<BehaviorTriggerRule>>((
  ref,
) {
  return [];
});

final behaviorTrackerProvider =
    StateNotifierProvider<BehaviorTrackerNotifier, BehaviorTrackerState>((ref) {
  return BehaviorTrackerNotifier(ref);
});

class BehaviorTrackerState {
  final Set<String> triggeredRules;
  final bool isChecking;

  BehaviorTrackerState({
    this.triggeredRules = const {},
    this.isChecking = false,
  });

  BehaviorTrackerState copyWith({
    Set<String>? triggeredRules,
    bool? isChecking,
  }) {
    return BehaviorTrackerState(
      triggeredRules: triggeredRules ?? this.triggeredRules,
      isChecking: isChecking ?? this.isChecking,
    );
  }
}

class BehaviorTrackerNotifier extends StateNotifier<BehaviorTrackerState> {
  final Ref ref;
  Timer? _checkTimer;

  BehaviorTrackerNotifier(this.ref) : super(BehaviorTrackerState()) {
    _startPeriodicCheck();
  }

  void _startPeriodicCheck() {
    _checkTimer?.cancel();
    _checkTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      checkRules();
    });
  }

  Future<void> checkRules() async {
    if (state.isChecking) return;

    state = state.copyWith(isChecking: true);

    try {
      final userState = ref.read(userProvider);
      final user = userState.user;

      if (user != null && !_hasLoadedBackendRules) {
        await _loadBackendRules();
      }

      final rules = ref.read(behaviorTriggerRulesProvider);
      final userStats = ref.read(userBehaviorStatsProvider);
      final userEventMap = userStats.toEventMap();

      for (final rule in rules) {
        if (!rule.enabled) {
          continue;
        }

        if (state.triggeredRules.contains(rule.ruleCode)) {
          continue;
        }

        final satisfied = rule.isSatisfied(userEventMap);

        if (satisfied) {
          await _triggerRule(rule);
        }
      }
    } catch (e) {
    } finally {
      state = state.copyWith(isChecking: false);
    }
  }

  bool _hasLoadedBackendRules = false;

  Future<void> _loadBackendRules() async {
    final userState = ref.read(userProvider);
    final user = userState.user;

    if (user == null) {
      return;
    }

    try {
      final adService = ref.read(adServiceProvider);
      final response = await adService.getBehaviorTriggerRules();
      final rules = response.data ?? [];

      if (rules.isNotEmpty) {
        ref.read(behaviorTriggerRulesProvider.notifier).state = rules;
      }
      _hasLoadedBackendRules = true;
    } catch (e) {
      _hasLoadedBackendRules = true;
    }
  }

  Future<Ad?> _triggerRule(BehaviorTriggerRule rule) async {
    final newTriggeredRules = Set<String>.from(state.triggeredRules)
      ..add(rule.ruleCode);
    state = state.copyWith(triggeredRules: newTriggeredRules);

    try {
      final deviceType = DeviceInfoHelper.instance.getPlatform();
      final appVersion = await AppPackageInfoUtil.getCurrentVersion();
      final ip = await DeviceInfoHelper.instance.getPublicIpAddress();
      final agentCode = AgentTracking.getStoredAgentCode();

      final adService = ref.read(adServiceProvider);
      final response = await adService.triggerAdByRule(
        ruleCode: rule.ruleCode,
        triggerRuleId: rule.id,
        deviceType: deviceType,
        appVersion: appVersion,
        ip: ip,
        agentCode: agentCode,
      );

      if (response.data != null) {
        final ad = response.data!;
        ad.ruleCode = rule.ruleCode;

        ref.read(triggeredAdProvider.notifier).state = ad;

        return ad;
      }
    } catch (e) {}

    return null;
  }

  void resetTriggeredRule(String ruleCode) {
    final newTriggeredRules = Set<String>.from(state.triggeredRules)
      ..remove(ruleCode);
    state = state.copyWith(triggeredRules: newTriggeredRules);
  }

  void resetAllTriggeredRules() {
    state = state.copyWith(triggeredRules: {});
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }
}

final triggeredAdProvider = StateProvider<Ad?>((ref) => null);

extension BehaviorTrackerExtension on WidgetRef {
  void trackEvent(BehaviorEventType eventType, {int amount = 1}) {
    read(
      userBehaviorStatsProvider.notifier,
    ).incrementEvent(eventType, amount: amount);
  }

  void trackBrowse() {
    trackEvent(BehaviorEventType.browseCount);
  }

  void trackLoadingComplete() {
    trackEvent(BehaviorEventType.loadingComplete);
    read(behaviorTrackerProvider.notifier).checkRules();
  }

  void trackVideoWatch() {
    trackEvent(BehaviorEventType.watchCount);
  }

  void trackStayDuration(int seconds) {
    trackEvent(BehaviorEventType.stayDuration, amount: seconds);
  }

  void trackLike() {
    trackEvent(BehaviorEventType.likeCount);
  }

  void trackComment() {
    trackEvent(BehaviorEventType.commentCount);
  }

  void trackShare() {
    trackEvent(BehaviorEventType.shareCount);
  }

  void trackPageVisit() {
    trackEvent(BehaviorEventType.pageVisitCount);
  }

  void trackAiChat() {
    trackEvent(BehaviorEventType.aiChatCount);
  }
}
