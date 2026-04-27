import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/constants/ad_placement.dart';
import 'package:live_app/models/ad.dart';
import 'package:live_app/provider/ad_provider.dart';
import 'package:live_app/provider/app_config_provider.dart';
import 'package:live_app/utils/ad_utils.dart';
import 'package:live_app/widgets/ad_badge.dart';
import 'package:live_app/widgets/empty_widget.dart';
import 'package:live_app/widgets/encrypted_image.dart';
import 'package:live_app/widgets/video/video_card.dart';
import 'package:live_app/widgets/video/video_card_cover.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../../models/video_info.dart';
import '../loading_widget.dart';

class VideoListSliver extends ConsumerStatefulWidget {
  final ProviderListenable provider;
  final Future<void> Function() onRefresh;
  final Function(VideoInfo videoInfo)? onUserTap;
  final int? videoType;

  const VideoListSliver({
    super.key,
    required this.provider,
    required this.onRefresh,
    this.onUserTap,
    this.videoType,
  });

  @override
  ConsumerState<VideoListSliver> createState() => _VideoListSliverState();
}

class _VideoListSliverState extends ConsumerState<VideoListSliver> {
  static const double _mobileLoadMoreThresholdPx = 720;
  static const double _webLoadMoreThresholdPx = 1800;
  static const double _mobileLoadMoreViewportFactor = 1.5;
  static const double _webLoadMoreViewportFactor = 3.0;
  bool _adsFetched = false;
  ScrollPosition? _scrollPosition;
  bool _loadMoreArmed = true;
  late Widget _contentSliverWidget;
  late Widget _footerSliverWidget;

  void _rebuildCachedSliverWidgets() {
    _contentSliverWidget = _VideoListContentSliver(
      provider: widget.provider,
      onUserTap: widget.onUserTap,
    );
    _footerSliverWidget = _VideoListLoadMoreSliver(provider: widget.provider);
  }

  double _loadMoreThresholdFor(ScrollPosition position) {
    final baseThreshold = kIsWeb
        ? _webLoadMoreThresholdPx
        : _mobileLoadMoreThresholdPx;
    final viewportFactor = kIsWeb
        ? _webLoadMoreViewportFactor
        : _mobileLoadMoreViewportFactor;
    final viewportThreshold = position.viewportDimension * viewportFactor;
    return baseThreshold > viewportThreshold
        ? baseThreshold
        : viewportThreshold;
  }

  void _attachScrollPosition() {
    final nextPosition = Scrollable.maybeOf(context)?.position;
    if (identical(_scrollPosition, nextPosition)) {
      return;
    }

    _scrollPosition?.removeListener(_handleScrollPositionChanged);
    _scrollPosition = nextPosition;
    _scrollPosition?.addListener(_handleScrollPositionChanged);
  }

  void _handleScrollPositionChanged() {
    final position = _scrollPosition;
    if (position == null ||
        !position.hasPixels ||
        !position.hasContentDimensions) {
      return;
    }

    final threshold = _loadMoreThresholdFor(position);
    final resetThreshold = threshold * 1.2;
    final isNearBottom = position.extentAfter <= threshold;
    if (!isNearBottom) {
      if (position.extentAfter >= resetThreshold) {
        _loadMoreArmed = true;
      }
      return;
    }

    if (!_loadMoreArmed ||
        position.userScrollDirection != ScrollDirection.reverse) {
      return;
    }

    final state = ref.read(widget.provider);
    if (state.loading || state.finished) {
      return;
    }

    _loadMoreArmed = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final nextState = ref.read(widget.provider);
      if (nextState.loading || nextState.finished) {
        return;
      }

      ref.read((widget.provider as dynamic).notifier).fetch(refresh: false);
    });
  }

  @override
  void initState() {
    super.initState();
    _rebuildCachedSliverWidgets();
    Future.microtask(() {
      if (_adsFetched) return;
      _adsFetched = true;
      ref
          .read(adListProvider(AdPlacement.videoFeedInFeed).notifier)
          .fetch(refresh: true);
    });
  }

  @override
  void didUpdateWidget(covariant VideoListSliver oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.provider != widget.provider ||
        oldWidget.onUserTap != widget.onUserTap ||
        oldWidget.videoType != widget.videoType) {
      _rebuildCachedSliverWidgets();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _attachScrollPosition();
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_handleScrollPositionChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = ref.watch(
      widget.provider.select((state) => state.list.isEmpty),
    );
    final isLoading = ref.watch(
      widget.provider.select((state) => state.loading),
    );
    final isFinished = ref.watch(
      widget.provider.select((state) => state.finished),
    );

    if ((!isFinished || isLoading) && isEmpty) {
      return const SliverFillRemaining(child: LoadingWidget());
    }
    if (isFinished && !isLoading && isEmpty) {
      return const SliverFillRemaining(child: EmptyWidget());
    }

    return SliverMainAxisGroup(
      slivers: [_contentSliverWidget, _footerSliverWidget],
    );
  }
}

class _VideoListContentSliver extends ConsumerStatefulWidget {
  const _VideoListContentSliver({
    required this.provider,
    required this.onUserTap,
  });

  final ProviderListenable provider;
  final Function(VideoInfo videoInfo)? onUserTap;

  @override
  ConsumerState<_VideoListContentSliver> createState() =>
      _VideoListContentSliverState();
}

class _VideoListContentSliverState
    extends ConsumerState<_VideoListContentSliver> {
  static const int _mobileCoverPrefetchCount = 6;
  static const int _webCoverPrefetchCount = 14;

  String? _initialWarmSignature;
  String? _lastObservedFirstVideoId;
  int _lastObservedVideoCount = 0;

  int get _coverPrefetchCount =>
      kIsWeb ? _webCoverPrefetchCount : _mobileCoverPrefetchCount;

  bool _isAdSlot(int displayIndex, int adsToInsert, int adsAfter) {
    if (adsToInsert == 0) return false;
    if ((displayIndex + 1) % (adsAfter + 1) != 0) return false;
    final adIndex = (displayIndex + 1) ~/ (adsAfter + 1) - 1;
    return adIndex < adsToInsert;
  }

  int _getAdIndex(int displayIndex, int adsAfter) {
    return (displayIndex + 1) ~/ (adsAfter + 1) - 1;
  }

  int _getVideoIndex(int displayIndex, int adsAfter, int adsToInsert) {
    final adsBeforeThis = _isAdSlot(displayIndex, adsToInsert, adsAfter)
        ? _getAdIndex(displayIndex, adsAfter)
        : (_getAdIndex(displayIndex, adsAfter) + 1).clamp(0, adsToInsert);
    return displayIndex - adsBeforeThis;
  }

  int _getAdsToInsert(int videoCount, int adCount, int adsAfter) {
    if (videoCount == 0 || adCount == 0) return 0;
    final maxAdsToInsert = videoCount ~/ adsAfter;
    return maxAdsToInsert < adCount ? maxAdsToInsert : adCount;
  }

  List<String> _buildCoverPrefetchUrls(
    List<VideoInfo> videos,
    int currentIndex,
  ) {
    final urls = <String>[];

    for (
      var i = currentIndex + 1;
      i < videos.length && urls.length < _coverPrefetchCount;
      i++
    ) {
      final url = videos[i].cover;
      if (url.isEmpty) {
        continue;
      }
      urls.add(url);
    }

    return urls;
  }

  void _scheduleInitialCoverWarm(List<VideoInfo> videos) {
    final urls = <String>[];
    for (
      var i = 0;
      i < videos.length && urls.length < _coverPrefetchCount;
      i++
    ) {
      final url = videos[i].cover;
      if (url.isEmpty) {
        continue;
      }
      urls.add(url);
    }

    if (urls.isEmpty) {
      return;
    }

    final signature = urls.join('|');
    if (_initialWarmSignature == signature) {
      return;
    }

    _initialWarmSignature = signature;
    unawaited(warmVideoCardCovers(ref, urls));
  }

  void _scheduleAppendedCoverWarm(List<VideoInfo> videos) {
    if (videos.isEmpty) {
      _lastObservedFirstVideoId = null;
      _lastObservedVideoCount = 0;
      return;
    }

    final firstVideoId = videos.first.id;
    final listReplaced =
        _lastObservedVideoCount > 0 &&
        (videos.length < _lastObservedVideoCount ||
            _lastObservedFirstVideoId != firstVideoId);
    final previousCount = listReplaced ? 0 : _lastObservedVideoCount;

    _lastObservedFirstVideoId = firstVideoId;
    _lastObservedVideoCount = videos.length;

    if (previousCount == 0 || videos.length <= previousCount) {
      return;
    }

    final urls = <String>[];
    for (var i = previousCount; i < videos.length; i++) {
      final url = videos[i].cover;
      if (url.isEmpty) {
        continue;
      }
      urls.add(url);
    }

    if (urls.isEmpty) {
      return;
    }

    unawaited(warmVideoCardCovers(ref, urls));
  }

  Widget _buildAdTile(Ad ad) {
    final url = ad.imageLargeUrl ?? ad.imageMediumUrl ?? ad.imageSmallUrl;
    if (url == null || url.isEmpty) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      key: ValueKey('video-feed-ad-${ad.id}'),
      behavior: HitTestBehavior.opaque,
      onTap: () {
        onAdRedirection(ad, ref);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 0.75,
          child: Stack(
            fit: StackFit.expand,
            children: [
              EncryptedImage(
                url: url,
                fit: BoxFit.cover,
                errorWidget: const Icon(Icons.broken_image, color: Colors.grey),
              ),
              const Positioned(top: 6, left: 6, child: AdBadge()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoTile(
    BuildContext context,
    List<VideoInfo> list,
    int displayIndex,
    int adsToInsert,
    int adsAfter,
    List<Ad> ads,
  ) {
    if (_isAdSlot(displayIndex, adsToInsert, adsAfter)) {
      final adIndex = _getAdIndex(displayIndex, adsAfter);
      if (adIndex < ads.length) {
        return _buildAdTile(ads[adIndex]);
      }
      return const SizedBox.shrink();
    }

    final videoIndex = _getVideoIndex(displayIndex, adsAfter, adsToInsert);
    if (videoIndex < 0 || videoIndex >= list.length) {
      return const SizedBox.shrink();
    }

    final item = list[videoIndex];
    return VideoCard(
      key: ValueKey('video-card-${item.id}'),
      video: item,
      onUserTap: widget.onUserTap,
      preloadCoverUrls: _buildCoverPrefetchUrls(list, videoIndex),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(widget.provider.select((state) => state.list));
    final ads = ref.watch(
      adListProvider(AdPlacement.videoFeedInFeed).select((state) => state.list),
    );
    final adsAfter = ref.watch(
      appConfigProvider.select((state) => state.data?.adsAfter ?? 5),
    );

    final int adCount = ads.length;
    final int adsToInsert = adsAfter > 0
        ? _getAdsToInsert(list.length, adCount, adsAfter)
        : 0;
    final int totalItemCount = list.length + adsToInsert;

    _scheduleInitialCoverWarm(list);
    _scheduleAppendedCoverWarm(list);

    return SliverWaterfallFlow(
      gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) =>
            _buildVideoTile(context, list, index, adsToInsert, adsAfter, ads),
        childCount: totalItemCount,
        addAutomaticKeepAlives: false,
      ),
    );
  }
}

class _VideoListLoadMoreSliver extends ConsumerWidget {
  const _VideoListLoadMoreSliver({required this.provider});

  static const double _footerExtent = 40;

  final ProviderListenable provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(provider.select((state) => state.loading));
    final isFinished = ref.watch(provider.select((state) => state.finished));
    final hasItems = ref.watch(
      provider.select((state) => state.list.isNotEmpty),
    );

    if (isLoading && hasItems) {
      return const SliverToBoxAdapter(
        child: SizedBox(
          height: _footerExtent,
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      );
    }

    if (isFinished) {
      return const SliverToBoxAdapter(child: SizedBox(height: _footerExtent));
    }

    return const SliverToBoxAdapter(child: SizedBox(height: _footerExtent));
  }
}
