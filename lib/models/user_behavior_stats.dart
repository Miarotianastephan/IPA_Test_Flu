import 'package:live_app/models/behavior_trigger_rule.dart';

class UserBehaviorStats {
  int browseCount;
  int loadingComplete;
  int watchCount;
  int stayDuration;
  int likeCount;
  int commentCount;
  int shareCount;
  int pageVisitCount;
  int aiChatCount;

  UserBehaviorStats({
    this.browseCount = 0,
    this.loadingComplete = 0,
    this.watchCount = 0,
    this.stayDuration = 0,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.pageVisitCount = 0,
    this.aiChatCount = 0,
  });

  Map<BehaviorEventType, int> toEventMap() {
    return {
      BehaviorEventType.browseCount: browseCount,
      BehaviorEventType.loadingComplete: loadingComplete,
      BehaviorEventType.watchCount: watchCount,
      BehaviorEventType.stayDuration: stayDuration,
      BehaviorEventType.likeCount: likeCount,
      BehaviorEventType.commentCount: commentCount,
      BehaviorEventType.shareCount: shareCount,
      BehaviorEventType.pageVisitCount: pageVisitCount,
      BehaviorEventType.aiChatCount: aiChatCount,
    };
  }

  void increment(BehaviorEventType eventType, {int amount = 1}) {
    switch (eventType) {
      case BehaviorEventType.browseCount:
        browseCount += amount;
        break;
      case BehaviorEventType.loadingComplete:
        loadingComplete += amount;
        break;
      case BehaviorEventType.watchCount:
        watchCount += amount;
        break;
      case BehaviorEventType.stayDuration:
        stayDuration += amount;
        break;
      case BehaviorEventType.likeCount:
        likeCount += amount;
        break;
      case BehaviorEventType.commentCount:
        commentCount += amount;
        break;
      case BehaviorEventType.shareCount:
        shareCount += amount;
        break;
      case BehaviorEventType.pageVisitCount:
        pageVisitCount += amount;
        break;
      case BehaviorEventType.aiChatCount:
        aiChatCount += amount;
        break;
      case BehaviorEventType.customCombination:
        // customCombination is not tracked directly
        break;
    }
  }

  void reset() {
    browseCount = 0;
    watchCount = 0;
    stayDuration = 0;
    likeCount = 0;
    commentCount = 0;
    shareCount = 0;
    pageVisitCount = 0;
    aiChatCount = 0;
  }

  void resetEvent(BehaviorEventType eventType) {
    switch (eventType) {
      case BehaviorEventType.browseCount:
        browseCount = 0;
        break;
      case BehaviorEventType.loadingComplete:
        loadingComplete = 0;
        break;
      case BehaviorEventType.watchCount:
        watchCount = 0;
        break;
      case BehaviorEventType.stayDuration:
        stayDuration = 0;
        break;
      case BehaviorEventType.likeCount:
        likeCount = 0;
        break;
      case BehaviorEventType.commentCount:
        commentCount = 0;
        break;
      case BehaviorEventType.shareCount:
        shareCount = 0;
        break;
      case BehaviorEventType.pageVisitCount:
        pageVisitCount = 0;
        break;
      case BehaviorEventType.aiChatCount:
        aiChatCount = 0;
        break;
      case BehaviorEventType.customCombination:
        break;
    }
  }

  UserBehaviorStats copyWith({
    int? browseCount,
    int? loadingComplete,
    int? watchCount,
    int? stayDuration,
    int? likeCount,
    int? commentCount,
    int? shareCount,
    int? pageVisitCount,
    int? aiChatCount,
  }) {
    return UserBehaviorStats(
      browseCount: browseCount ?? this.browseCount,
      loadingComplete: loadingComplete ?? this.loadingComplete,
      watchCount: watchCount ?? this.watchCount,
      stayDuration: stayDuration ?? this.stayDuration,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      pageVisitCount: pageVisitCount ?? this.pageVisitCount,
      aiChatCount: aiChatCount ?? this.aiChatCount,
    );
  }

  @override
  String toString() {
    return 'UserBehaviorStats(browseCount: $browseCount, watchCount: $watchCount, '
        'stayDuration: $stayDuration, likeCount: $likeCount, commentCount: $commentCount, '
        'shareCount: $shareCount, pageVisitCount: $pageVisitCount, aiChatCount: $aiChatCount)';
  }
}
