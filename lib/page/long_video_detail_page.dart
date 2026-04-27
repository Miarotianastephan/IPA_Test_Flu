import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/constants/ad_placement.dart';
import 'package:live_app/models/ad_video.dart';
import 'package:live_app/models/video_info.dart';
import 'package:live_app/provider/ad_provider.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/provider/timer_provider.dart';
import 'package:live_app/provider/video_detail_provider.dart';
import 'package:live_app/utils/app_route_observer.dart';
import 'package:live_app/widgets/video/encrypted_hls_player.dart';
import 'package:live_app/widgets/video/mobile_video_player.dart';
import 'package:live_app/widgets/video_screen.dart';

import '../provider/ad_video_provider.dart';
import '../widgets/ad_cover_image_screen.dart';
import '../widgets/ad_video_player_screen.dart';
import '../widgets/video/comment_section.dart';
import '../widgets/video/video_description_section.dart';

class LongVideoDetailPage extends ConsumerStatefulWidget {
  final VideoInfo video;

  const LongVideoDetailPage({super.key, required this.video});

  @override
  ConsumerState<LongVideoDetailPage> createState() =>
      _LongVideoDetailPageState();
}

class _LongVideoDetailPageState extends ConsumerState<LongVideoDetailPage>
    with SingleTickerProviderStateMixin, RouteAware {
  late TabController _tabController;
  late VideoScreenController _videoController;

  bool _isAdPlaying = false;
  bool _isNavigatingToRecommended = false;
  EncryptedHlsPlayerController? _encryptedController;
  ProviderSubscription<TimerState>? _timerSubscription;
  PageRoute<dynamic>? _route;
  final Set<int> _processedAdDurations = {};
  bool _allAdsProcessed = false;

  bool get _isCurrentRoute {
    final route = ModalRoute.of(context);
    return mounted && route != null && route.isCurrent;
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _tabController = TabController(length: 2, vsync: this);
    _videoController = VideoScreenController();
    _encryptedController = EncryptedHlsPlayerController();
    _timerSubscription = ref.listenManual(timerProvider, (previous, next) {
      if (_isCurrentRoute) {
        _checkTimerEvents();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _processedAdDurations.clear();
      ref.read(timerProvider.notifier).reset();
      ref.read(timerProvider.notifier).start();
      unawaited(getAdVideoList());
      unawaited(markSeen());
      unawaited(
        Future<void>.delayed(const Duration(milliseconds: 120), () {
          if (!mounted || !_isCurrentRoute) return;
          _playVideo(widget.video);
        }),
      );
    });

    Future.microtask(() async {
      ref
          .read(adListProvider(AdPlacement.videoBottomBanner).notifier)
          .fetch(refresh: true);
    });
  }

  Future<void> markSeen() async {
    await ref
        .read(videoDetailProvider(widget.video.id).notifier)
        .loadVideoDetail(widget.video.id);
    if (!mounted) return;
    ref.read(videoDetailProvider(widget.video.id).notifier).markSeen();
  }

  void _playVideo(VideoInfo video) async {
    final resume = _videoController.resume ?? _videoController.play;
    if (kIsWeb) {
      resume?.call();
    } else if (video.encryptionKey != null && _encryptedController != null) {
      _encryptedController!.play?.call();
    } else {
      resume?.call();
    }
  }

  void _pauseVideo(VideoInfo video) async {
    if (kIsWeb) {
      _videoController.pause?.call();
    } else if (video.encryptionKey != null && _encryptedController != null) {
      _encryptedController!.pause?.call();
    } else {
      _videoController.pause?.call();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (_route == route || route is! PageRoute<dynamic>) return;

    if (_route != null) {
      appRouteObserver.unsubscribe(this);
    }

    _route = route;
    appRouteObserver.subscribe(this, route);
  }

  @override
  void didPushNext() {
    if (!_isNavigatingToRecommended) return;
    _isNavigatingToRecommended = true;
    ref.read(timerProvider.notifier).stop();
    _pauseVideo(widget.video);
  }

  @override
  void didPopNext() {
    if (!_isNavigatingToRecommended) return;
    ref.read(timerProvider.notifier).start();
    _playVideo(widget.video);
    _isNavigatingToRecommended = false;
  }

  Future<void> _checkTimerEvents() async {
    if (!_isCurrentRoute || _isNavigatingToRecommended) return;

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

    for (final config in matchingConfigs) {
      final ads = config.adVideos;
      if (ads != null && ads.isNotEmpty) {
        _pauseVideo(widget.video);

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
    }

    _isAdPlaying = false;
  }

  Future<void> _playAdVideoFullscreen(String videoUrl, int duration) async {
    if (!_isCurrentRoute) {
      return;
    }

    final isFullscreen = ref.read(fullscreenProvider);
    if (kIsWeb) {
      ref.read(fullscreenProvider.notifier).state = false;
    }

    String? preloadedProxyUrl;
    String? preloadedSessionId;
    if (!kIsWeb) {
      final preloadService = ref.read(adVideoPreloadServiceProvider);
      final preloaded = preloadService.getPreloaded(videoUrl);
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
          onVideoFinished: () {
            if (isFullscreen) {
              if (kIsWeb) {
                ref.read(fullscreenProvider.notifier).state = true;
              } else {
                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.landscapeLeft,
                  DeviceOrientation.landscapeRight,
                ]);
                SystemChrome.setEnabledSystemUIMode(
                  SystemUiMode.immersiveSticky,
                );
              }
            }
          },
        ),
      ),
    );

    if (mounted && _isCurrentRoute) {
      _playVideo(widget.video);
    }
  }

  Future<void> toggleFullscreen() async {
    final isFullscreen = ref.read(fullscreenProvider);
    ref.read(fullscreenProvider.notifier).state = !isFullscreen;

    if (!kIsWeb) {
      if (isFullscreen) {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      } else {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> _showAdCoverImageFullscreen(
    String coverImageUrl,
    int duration, {
    AdTargetType? targetType,
    String? jumpUrl,
    String? claimUrl,
  }) async {
    bool isFullscreen = ref.read(fullscreenProvider);

    if (kIsWeb) {
      ref.read(fullscreenProvider.notifier).state = false;
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      useSafeArea: false,
      builder: (context) => AdCoverImageScreen(
        coverImageUrl: coverImageUrl,
        duration: duration,
        targetType: targetType,
        jumpUrl: jumpUrl,
        claimUrl: claimUrl,
        onAdFinished: () {
          if (isFullscreen) {
            if (kIsWeb) {
              ref.read(fullscreenProvider.notifier).state = true;
            } else {
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.landscapeLeft,
                DeviceOrientation.landscapeRight,
              ]);
              SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
            }
          }
        },
      ),
    );

    if (mounted && _isCurrentRoute) {
      _playVideo(widget.video);
    }
  }

  Future<void> getAdVideoList() async {
    final adVideoState = ref.read(adVideoListProvider);
    if (adVideoState.adVideoConfigs.isEmpty) {
      await ref.read(adVideoListProvider.notifier).loadAdVideos();
    }

    if (!kIsWeb) {
      _preloadAdVideos();
    }
  }

  Future<void> _preloadAdVideos() async {
    final adVideoState = ref.read(adVideoListProvider);
    final preloadService = ref.read(adVideoPreloadServiceProvider);

    for (final config in adVideoState.adVideoConfigs) {
      final ads = config.adVideos;
      if (ads != null && ads.isNotEmpty) {
        for (final ad in ads) {
          if (ad.videoUrl != null) {
            await preloadService.preloadVideo(ad.videoUrl!, 'xokey');
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _timerSubscription?.close();
    if (_route != null) {
      appRouteObserver.unsubscribe(this);
    }
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _tabController.dispose();
    ref.read(timerProvider.notifier).stop();
    if (!kIsWeb) {
      ref.read(adVideoPreloadServiceProvider).clearAll();
    }
    super.dispose();
  }

  Future<void> _pauseAndNavigate(VideoInfo video) async {
    _isNavigatingToRecommended = true;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LongVideoDetailPage(video: video)),
    );
    if (mounted && _isCurrentRoute && _isNavigatingToRecommended) {
      _isNavigatingToRecommended = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final videoState = ref.watch(videoDetailProvider(widget.video.id));
    final videoNotifier = ref.read(
      videoDetailProvider(widget.video.id).notifier,
    );
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);
    final video = videoState.video;

    final isFullscreen = ref.watch(fullscreenProvider);
    return PopScope(
      canPop: isFullscreen ? false : true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && mounted) {
          ref.read(timerProvider.notifier).stop();
          ref.read(fullscreenProvider.notifier).state = false;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Stack(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.97,
                      child: Center(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final ratio = isFullscreen
                                ? constraints.maxWidth / constraints.maxHeight
                                : 16 / 9;

                            return Column(
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    AspectRatio(
                                      aspectRatio: ratio,
                                      child: VideoScreen(
                                        encryptionKey:
                                            video?.encryptionKey ??
                                            widget.video.encryptionKey,
                                        videoUrl: widget.video.url,
                                        controller: _videoController,
                                        encryptedController:
                                            _encryptedController,
                                        autoPlay: true,
                                        videoId: widget.video.id,
                                      ),
                                    ),
                                  ],
                                ),
                                ref.watch(fullscreenProvider) == true
                                    ? SizedBox.shrink()
                                    : Flexible(
                                        child: Container(
                                          color: const Color(0xFF111111),
                                          child: Column(
                                            children: [
                                              Container(
                                                color: const Color(0xFF111111),
                                                child: TabBar(
                                                  controller: _tabController,
                                                  labelColor: Colors.white,
                                                  unselectedLabelColor:
                                                      Colors.grey,
                                                  indicatorColor: Colors.white,
                                                  tabs: [
                                                    Tab(
                                                      text: translate("intro"),
                                                    ),
                                                    Tab(
                                                      text: translate(
                                                        "comment",
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                child: TabBarView(
                                                  controller: _tabController,
                                                  children: [
                                                    VideoDescriptionSection(
                                                      videoInfo:
                                                          video ?? widget.video,
                                                      onRecommendedVideoTap:
                                                          _pauseAndNavigate,
                                                      onFavorite: (v) =>
                                                          videoNotifier
                                                              .toggleFavorite(),
                                                      onLike: (v) async {
                                                        videoNotifier
                                                            .toggleLike();
                                                      },
                                                      onFollowPressed:
                                                          (v) async {
                                                            videoNotifier
                                                                .toggleFollow();
                                                          },
                                                      onShare: () =>
                                                          videoNotifier
                                                              .shareVideo(),
                                                    ),
                                                    CommentSection(
                                                      videoId: widget.video.id,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Development Timer Display (bottom center)
            // Positioned(
            //   bottom: 20,
            //   left: 0,
            //   right: 0,
            //   child: Center(
            //     child: Container(
            //       padding: const EdgeInsets.symmetric(
            //         horizontal: 16,
            //         vertical: 8,
            //       ),
            //       decoration: BoxDecoration(
            //         color: Colors.black87,
            //         borderRadius: BorderRadius.circular(20),
            //         border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            //       ),
            //       child: Row(
            //         mainAxisSize: MainAxisSize.min,
            //         children: [
            //           Text(
            //             timerState.formattedTime,
            //             style: const TextStyle(
            //               color: Colors.white,
            //               fontSize: 14,
            //               fontWeight: FontWeight.bold,
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            if (!isFullscreen)
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 10,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: Navigator.of(context).pop,
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: 28,
                        shadows: [
                          Shadow(
                            color: Color(0xE6000000),
                            blurRadius: 12,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
