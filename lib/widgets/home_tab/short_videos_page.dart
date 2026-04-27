import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/ad_video.dart';
import 'package:live_app/provider/ad_video_provider.dart';
import 'package:live_app/provider/app_config_provider.dart';
import 'package:live_app/constants/ad_placement.dart';
import 'package:live_app/provider/ad_provider.dart';
import 'package:live_app/provider/behavior_tracker_provider.dart';
import 'package:live_app/provider/cumulative_watch_time_provider.dart';
import 'package:live_app/provider/current_tab_provider.dart';
import 'package:live_app/provider/timer_provider.dart';
import 'package:live_app/services/ad_video_preload_service.dart';

import '../../models/video_info.dart';
import '../../provider/home_video_list_provider.dart';
import '../../models/video_list_state.dart';
import '../ad_cover_image_screen.dart';
import '../ad_video_player_screen.dart';
import '../empty_widget.dart';
import '../encrypted_image.dart';
import '../loading_widget.dart';
import '../video/short_video_item.dart';
import 'ad_short_video.dart';

class ShortVideosPage extends ConsumerStatefulWidget {
  final PageController controller;
  final int currentIndex;
  final int tabIndex;
  final bool isActive;
  final ValueChanged<int>? onPageChanged;
  final int type;
  final Function(VideoInfo videoInfo) onUserTap; // 新增：点击头像回调
  final VoidCallback onShowComment; //当显示评论的时候
  final VoidCallback onHideComment; //当隐藏评论的时候
  final Function(int, bool) hasData; //当没有数据的时候

  const ShortVideosPage({
    super.key,
    required this.controller,
    required this.currentIndex,
    required this.isActive,
    required this.type,
    required this.onUserTap,
    required this.onShowComment,
    required this.onHideComment,
    required this.hasData,
    this.onPageChanged,
    required this.tabIndex,
  });

  @override
  ConsumerState<ShortVideosPage> createState() => ShortVideosPageState();
}

class ShortVideosPageState extends ConsumerState<ShortVideosPage>
    with WidgetsBindingObserver {
  bool _commentVisible = false;
  int _lastReportedPage = 0;
  int _lastPreloadVideoIndex = 0;
  String? _lastPaginationTriggerKey;
  static const int _paginationThreshold = 5;
  final Map<int, ShortVideoItemController> _itemControllers = {};
  late ProviderSubscription<bool> _sub;
  ProviderSubscription<VideoListState>? _homeVideoStateSub;
  bool _didInitialFetch = false;

  bool _isAdPlaying = false;
  AdVideoPreloadService? _preloadService;
  final Set<int> _processedAdDurations = {};
  bool _allAdsProcessed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lastReportedPage = widget.currentIndex;

    _sub = ref.listenManual<bool>(currentTabProvider, (previous, next) {});

    Future.microtask(_ensureInitialDataLoaded);
    _subscribeHomeVideoState();
    widget.controller.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!kIsWeb) {
        _preloadService = ref.read(adVideoPreloadServiceProvider);
      }
      _processedAdDurations.clear();
      ref.read(timerProvider.notifier).reset();
      ref.read(timerProvider.notifier).start();
      await _getAdVideoList();
    });
  }

  Future<void> _ensureInitialDataLoaded() async {
    if (!mounted || _didInitialFetch || !widget.isActive) return;

    _didInitialFetch = true;
    await fetch(refresh: true);

    if (!mounted) return;

    final adNotifier = ref.read(
      adListProvider(AdPlacement.videoFeedInFeed).notifier,
    );
    final adState = ref.read(adListProvider(AdPlacement.videoFeedInFeed));
    if (adState.list.isEmpty && !adState.loading) {
      await adNotifier.fetch(refresh: true);
    }

    if (kIsWeb) {
      final state = ref.read(homeVideoListProvider((widget.type, 0)));
      final notifier = ref.read(
        homeVideoListProvider((widget.type, 0)).notifier,
      );
      final preloadList = state.list.take(5).toList();
      notifier.preLoadImage(preloadList);
      _lastPreloadVideoIndex = preloadList.length;
    }
  }

  void _subscribeHomeVideoState() {
    _homeVideoStateSub?.close();
    _homeVideoStateSub = ref.listenManual<VideoListState>(
      homeVideoListProvider((widget.type, 0)),
      (previous, next) {
        _handleOffsetChange(previous?.offset, next.offset);
      },
    );
  }

  void _handleOffsetChange(int? previousOffset, int currentOffset) {
    if (previousOffset == null || currentOffset <= previousOffset) return;
    if (!widget.controller.hasClients) return;

    final adsAfter = ref.read(appConfigProvider).data?.adsAfter ?? 10;
    final diff = currentOffset - previousOffset;
    final currentPage = widget.controller.page ?? 0;
    final displayDiff = diff + (diff ~/ adsAfter);
    final newPage = (currentPage - displayDiff).clamp(0, double.infinity);
    final viewport = widget.controller.position.viewportDimension;

    if (viewport <= 0) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.controller.hasClients) return;
      widget.controller.jumpTo(newPage * viewport);
    });
  }

  @override
  void didUpdateWidget(covariant ShortVideosPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.type != widget.type) {
      _didInitialFetch = false;
      _lastPaginationTriggerKey = null;
      _lastPreloadVideoIndex = 0;
      _subscribeHomeVideoState();
    }
    if (!oldWidget.isActive && widget.isActive) {
      Future.microtask(_ensureInitialDataLoaded);
      ref.read(timerProvider.notifier).start();
    } else if (oldWidget.isActive && !widget.isActive) {
      ref.read(timerProvider.notifier).pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sub.close();
    _homeVideoStateSub?.close();
    for (final controller in _itemControllers.values) {
      controller.dispose();
    }
    widget.controller.removeListener(_onScroll);
    ref.read(cumulativeWatchTimeProvider.notifier).stopTracking();
    ref.read(timerProvider.notifier).stop();
    if (!kIsWeb) {
      _preloadService?.clearAll();
    }
    super.dispose();
  }

  Future<void> _getAdVideoList() async {
    final adVideoState = ref.read(adVideoListProvider);
    if (adVideoState.adVideoConfigs.isEmpty) {
      await ref.read(adVideoListProvider.notifier).loadAdVideos();
    }

    if (!kIsWeb) {
      _preloadAdVideos();
    }
  }

  Future<void> _preloadAdVideos() async {
    if (_preloadService == null) return;
    final adVideoState = ref.read(adVideoListProvider);

    for (final config in adVideoState.adVideoConfigs) {
      final ads = config.adVideos;
      if (ads != null && ads.isNotEmpty) {
        for (final ad in ads) {
          if (ad.videoUrl != null) {
            await _preloadService!.preloadVideo(ad.videoUrl!, 'xokey');
          }
        }
      }
    }
  }

  Future<void> _checkTimerEvents() async {
    final currentMainTab = ref.read(currentTabIndexProvider);
    if (currentMainTab != 0) return;

    final timerState = ref.read(timerProvider);
    final adVideoState = ref.read(adVideoListProvider);

    if (adVideoState.adVideoConfigs.isEmpty) {
      return;
    }

    if (_isAdPlaying) {
      return;
    }

    final adDurations =
        adVideoState.adVideoConfigs
            .map((config) => config.durationSeconds)
            .toSet()
            .toList()
          ..sort();

    final missedDurations = adDurations
        .where(
          (duration) =>
              timerState.seconds >= duration &&
              !_processedAdDurations.contains(duration),
        )
        .toList();

    if (_processedAdDurations.length >= adDurations.length) {
      if (!_allAdsProcessed) {
        _allAdsProcessed = true;
      }
      return;
    }

    if (missedDurations.isEmpty) {
      return;
    }

    final currentDuration = missedDurations.first;
    _processedAdDurations.add(currentDuration);

    final matchingConfigs = adVideoState.adVideoConfigs.where(
      (config) => config.durationSeconds == currentDuration,
    );

    final hasAdsToPlay = matchingConfigs.any(
      (config) => config.adVideos != null && config.adVideos!.isNotEmpty,
    );

    if (!hasAdsToPlay) {
      return;
    }

    _isAdPlaying = true;

    final currentController = _itemControllers[_lastReportedPage];
    currentController?.pause();

    for (final config in matchingConfigs) {
      final ads = config.adVideos;
      if (ads != null && ads.isNotEmpty) {
        for (final ad in ads) {
          ref.read(timerProvider.notifier).pause();
          if (ad.videoUrl != null && ad.videoUrl!.isNotEmpty) {
            await _playAdVideoFullscreen(ad.videoUrl!, ad.duration);
          } else if (ad.coverImage != null && ad.coverImage!.isNotEmpty) {
            await _showAdCoverImageFullscreen(
              ad.coverImage!,
              ad.duration,
              targetType: ad.targetType,
              jumpUrl: ad.jumpUrl,
              claimUrl: ad.claimUrl,
            );
          }
        }
      }
    }

    if (mounted) {
      ref.read(timerProvider.notifier).resume();
      final currentController = _itemControllers[_lastReportedPage];
      currentController?.play();
    }

    _isAdPlaying = false;
  }

  Future<void> _playAdVideoFullscreen(String videoUrl, int duration) async {
    String? preloadedProxyUrl;
    String? preloadedSessionId;
    if (!kIsWeb) {
      final preloaded = _preloadService?.getPreloaded(videoUrl);
      if (preloaded != null) {
        preloadedProxyUrl = preloaded.proxyUrl;
        preloadedSessionId = preloaded.sessionId;
      }
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AdVideoPlayerScreen(
          videoUrl: videoUrl,
          encryptionKey: 'xokey',
          duration: duration,
          preloadedProxyUrl: preloadedProxyUrl,
          preloadedSessionId: preloadedSessionId,
          onVideoFinished: () {},
        ),
      ),
    );
  }

  Future<void> _showAdCoverImageFullscreen(
    String coverImageUrl,
    int duration, {
    AdTargetType? targetType,
    String? jumpUrl,
    String? claimUrl,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AdCoverImageScreen(
          coverImageUrl: coverImageUrl,
          duration: duration,
          targetType: targetType,
          jumpUrl: jumpUrl,
          claimUrl: claimUrl,
          onAdFinished: () {},
        ),
      ),
    );
  }

  ShortVideoItemController _getController(int index) {
    return _itemControllers.putIfAbsent(
      index,
      () => ShortVideoItemController(),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      ref.read(cumulativeWatchTimeProvider.notifier).stopTracking();
    }
  }

  void _onScroll() {
    if (!widget.controller.hasClients) return;

    final double pageDouble = widget.controller.page ?? 0;
    final int page = pageDouble.round();

    if (page != _lastReportedPage) {
      _lastReportedPage = page;
      widget.onPageChanged?.call(page);
      final adsAfter = ref.read(appConfigProvider).data?.adsAfter ?? 10;
      final state = ref.read(homeVideoListProvider((widget.type, 0)));
      final notifier = ref.read(
        homeVideoListProvider((widget.type, 0)).notifier,
      );

      _maybePreloadImages(page, adsAfter, state, notifier);
      _maybeLoadMore(page, adsAfter, state, notifier);
    }
  }

  void _maybePreloadImages(
    int page,
    int adsAfter,
    VideoListState state,
    HomeVideoListNotifier notifier,
  ) {
    if (!kIsWeb || page % 5 != 0) return;

    final adCount = ref
        .read(adListProvider(AdPlacement.videoFeedInFeed))
        .list
        .length;
    final realVideoIndex = _getRealVideoIndex(page, adsAfter, adCount);
    if (realVideoIndex + 5 <= _lastPreloadVideoIndex ||
        _lastPreloadVideoIndex >= state.list.length) {
      return;
    }

    final end = (_lastPreloadVideoIndex + 5).clamp(0, state.list.length);
    final preloadList = state.list.sublist(_lastPreloadVideoIndex, end);
    notifier.preLoadImage(preloadList);
    _lastPreloadVideoIndex = end;
  }

  void _maybeLoadMore(
    int page,
    int adsAfter,
    VideoListState state,
    HomeVideoListNotifier notifier,
  ) {
    final adCount = ref
        .read(adListProvider(AdPlacement.videoFeedInFeed))
        .list
        .length;
    final int realVideoIndex = _getRealVideoIndex(page, adsAfter, adCount);
    final int thresholdIndex = state.list.length - _paginationThreshold;
    if (realVideoIndex < thresholdIndex) return;

    final triggerKey =
        '${state.offset}-${state.list.length}-${state.finished}-${state.loading}';
    if (_lastPaginationTriggerKey == triggerKey) return;
    _lastPaginationTriggerKey = triggerKey;

    if (state.finished) {
      notifier.recycleVideos();
    } else if (!state.loading) {
      notifier.fetch();
    }
  }

  int _getRealVideoIndex(int displayIndex, int adsAfter, int adCount) {
    if (adCount <= 0) return displayIndex;
    final adsBefore = (displayIndex + 1) ~/ (adsAfter + 1);
    return displayIndex - adsBefore;
  }

  bool _isAdPage(int displayIndex, int adCount, int adsAfter) {
    if (adCount == 0) return false;
    return (displayIndex + 1) % (adsAfter + 1) == 0;
  }

  int _getTotalItemCount(int videoCount, int adCount, int adsAfter) {
    if (videoCount == 0) return 0;
    return videoCount + (videoCount ~/ adsAfter);
  }

  Future<void> fetch({bool refresh = false}) async {
    try {
      final notifier = ref.read(
        homeVideoListProvider((widget.type, 0)).notifier,
      );
      final state = ref.read(homeVideoListProvider((widget.type, 0)));

      // 如果正在加载或已加载完毕且不是刷新，就不重复加载
      if (state.loading || (state.finished && !refresh)) return;

      if (refresh) {
        _lastPaginationTriggerKey = null;
        _lastPreloadVideoIndex = 0;
      }

      // 调用 Provider 的 fetchVideos 方法
      await notifier.fetch(refresh: refresh);
      if (!mounted) return;

      final newState = ref.read(homeVideoListProvider((widget.type, 0)));

      // 更新外层状态
      if (refresh && newState.list.isEmpty) {
        widget.hasData(widget.tabIndex, false);
      } else {
        widget.hasData(widget.tabIndex, true);
      }
    } catch (e, st) {
      debugPrint("${refresh ? '刷新' : '加载更多'}视频失败: $e");
      debugPrintStack(stackTrace: st);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeVideoListProvider((widget.type, 0)));
    final adState = ref.watch(adListProvider(AdPlacement.videoFeedInFeed));
    final adsAfter = ref.watch(appConfigProvider).data?.adsAfter ?? 10;

    ref.listen(timerProvider, (previous, next) {
      final isCurrent = ModalRoute.of(context)?.isCurrent ?? false;
      if (mounted && widget.isActive && isCurrent) {
        _checkTimerEvents();
      }
    });

    final notifier = ref.read(homeVideoListProvider((widget.type, 0)).notifier);
    Widget child;

    if (state.loading && state.list.isEmpty) {
      child = Container(color: Colors.black, child: const LoadingWidget());
    } else if (!state.loading && state.list.isEmpty) {
      child = CustomScrollView(
        controller: widget.controller,
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).size.height + 1,
              child: const EmptyWidget(),
            ),
          ),
        ],
      );
    } else {
      final int adCount = adState.list.length;
      final int totalItemCount = _getTotalItemCount(
        state.list.length,
        adCount,
        adsAfter,
      );
      child = PageView.builder(
        key: ValueKey('pageview_${widget.type}'),
        controller: widget.controller,
        scrollDirection: Axis.vertical,
        allowImplicitScrolling: true,
        itemCount: totalItemCount,
        onPageChanged: (index) {
          ref.trackBrowse();
          final availableAdCount = ref
              .read(adListProvider(AdPlacement.videoFeedInFeed))
              .list
              .length;
          final adIndex = index ~/ (adsAfter + 1);
          final shouldPrefetchNextAd =
              (index + 1) % (adsAfter + 1) == 0 &&
              adIndex >= availableAdCount - 1;

          if (shouldPrefetchNextAd) {
            final currentAdState = ref.read(
              adListProvider(AdPlacement.videoFeedInFeed),
            );
            if (!currentAdState.loading && !currentAdState.finished) {
              ref
                  .read(adListProvider(AdPlacement.videoFeedInFeed).notifier)
                  .fetch(limit: 5);
            }
          }
        },
        itemBuilder: (context, index) {
          if (_isAdPage(index, adCount, adsAfter)) {
            final rawAdIndex = index ~/ (adsAfter + 1);
            final adIndex = rawAdIndex % adCount;
            final ad = adState.list[adIndex];
            return KeyedSubtree(
              key: ValueKey('home-page-ad-${widget.type}-$index-${ad.id}'),
              child: AdShortVideo(ad: ad),
            );
          }

          final int videoIndex = _getRealVideoIndex(index, adsAfter, adCount);
          if (videoIndex >= state.list.length) {
            return KeyedSubtree(
              key: ValueKey('home-page-empty-${widget.type}-$index'),
              child: Container(color: Colors.black),
            );
          }

          final item = state.list[videoIndex];
          if ((index - _lastReportedPage).abs() > 1) {
            return KeyedSubtree(
              key: ValueKey('home-page-cover-${widget.type}-$index-${item.id}'),
              child: EncryptedImage(url: item.cover),
            );
          }

          return KeyedSubtree(
            key: ValueKey('home-page-video-${widget.type}-$index-${item.id}'),
            child: ShortVideoItem(
              pageKey: "Home",
              key: ValueKey('video_${widget.type}_${item.id}'),
              controller: _getController(index),
              isFirstItem: index == 0,
              onReset: () {},
              onBufferingChanged: (isBuffering) {
                if (!isBuffering) {
                  if (mounted) {}
                }
              },
              onInitialized: () {
                if (!mounted) return;
              },
              onShowComment: () {
                if (!_commentVisible) {
                  setState(() => _commentVisible = true);
                  widget.onShowComment();
                }
              },
              onHideComment: () {
                if (_commentVisible) {
                  setState(() => _commentVisible = false);
                  widget.onHideComment();
                }
              },
              videoInfo: item,
              onUserTap: widget.onUserTap,
              onVideoInfoChange: (updatedVideo) {
                if (item.isFollow != updatedVideo.isFollow) {
                  notifier.updateFollowStatus(
                    updatedVideo.user.id,
                    updatedVideo.isFollow,
                  );
                }
                notifier.updateVideo(updatedVideo);
              },
            ),
          );
        },
      );
    }

    return Stack(children: [child]);
  }
}
