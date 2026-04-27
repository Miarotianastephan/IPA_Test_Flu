import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/video_info.dart';
import 'package:live_app/page/long_video_detail_page.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/provider/purchased_contents_provider.dart';
import 'package:live_app/widgets/video/video_grid_item.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../page/short_video_detail_page.dart';
import '../page/user_detail_page.dart';
import '../services/payment_orchestrator.dart';
import '../utils/utils.dart';
import 'empty_retry.dart';
import 'payment/price_bottom_sheet.dart';

class GeneralVideoTab extends ConsumerStatefulWidget {
  final bool loading;
  final List<VideoInfo> results;
  final bool isLoaded;
  final VoidCallback onRefresh;
  final VoidCallback onLoadMore;
  final bool finished;
  final dynamic provider;
  final String? scrollStorageKey;
  final bool hideUserInfo;
  final bool showDeleteButton;
  final void Function(int index)? onDelete;

  const GeneralVideoTab({
    super.key,
    required this.loading,
    required this.results,
    required this.isLoaded,
    required this.onRefresh,
    required this.onLoadMore,
    required this.finished,
    required this.provider,
    this.scrollStorageKey,
    this.hideUserInfo = false,
    this.showDeleteButton = false,
    this.onDelete,
  });

  @override
  ConsumerState<GeneralVideoTab> createState() => _GeneralVideoTabState();
}

class _GeneralVideoTabState extends ConsumerState<GeneralVideoTab> {
  static const int _mobileCoverPrefetchCount = 6;
  static const int _webCoverPrefetchCount = 14;

  int? _activeHeroIndex;

  int get _coverPrefetchCount =>
      kIsWeb ? _webCoverPrefetchCount : _mobileCoverPrefetchCount;

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

  List<({int sourceIndex, VideoInfo video})> _shortVideoEntries(
    List<VideoInfo> videos,
  ) {
    return [
      for (int i = 0; i < videos.length; i++)
        if (videos[i].type == 1) (sourceIndex: i, video: videos[i]),
    ];
  }

  void _handlePurchaseSuccess(
    VideoInfo video,
    int sourceIndex,
    List<({int sourceIndex, VideoInfo video})> shortVideoEntries,
  ) {
    if (!mounted) return;
    ref
        .read(purchasedContentProvider.notifier)
        .markAsPurchased('video', video.id);
    _openVideoDetail(video, sourceIndex, shortVideoEntries);
  }

  void _openVideoDetail(
    VideoInfo video,
    int sourceIndex,
    List<({int sourceIndex, VideoInfo video})> shortVideoEntries,
  ) {
    if (video.type == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => LongVideoDetailPage(video: video)),
      );
      return;
    }

    final shortVideoIndex = shortVideoEntries.indexWhere(
      (entry) => entry.sourceIndex == sourceIndex,
    );
    if (shortVideoIndex == -1) {
      return;
    }

    setState(() => _activeHeroIndex = sourceIndex);
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) =>
            ShortVideoDetailPage(
              heroTagPrefix: "search_grid",
              initialIndex: shortVideoIndex,
              isUserDetailPop: true,
              provider: widget.provider,
              selectVideos: (state) => state.list
                  .whereType<VideoInfo>()
                  .where((item) => item.type == 1)
                  .toList(),
              onPageChanged: (newIndex) {
                if (newIndex >= 0 && newIndex < shortVideoEntries.length) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    setState(() {
                      _activeHeroIndex =
                          shortVideoEntries[newIndex].sourceIndex;
                    });
                  });
                }

                if (newIndex >= shortVideoEntries.length - 2 &&
                    !widget.loading &&
                    !widget.finished) {
                  widget.onLoadMore();
                }
              },
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ).then((_) {
      if (mounted) {
        setState(() => _activeHeroIndex = null);
      }
    });
  }

  Future<void> _handleWalletPayment(
    VideoInfo video,
    int sourceIndex,
    List<({int sourceIndex, VideoInfo video})> shortVideoEntries,
  ) async {
    if (!mounted) return;

    final orchestrator = PaymentOrchestrator(ref, context);
    final success = await orchestrator.purchaseContent(
      contentType: 'video',
      contentId: video.id,
      price: video.price,
      contentTitle: video.title,
    );

    if (success && mounted) {
      _handlePurchaseSuccess(video, sourceIndex, shortVideoEntries);
    }
  }

  Future<void> _handleDirectPayment(
    VideoInfo video,
    int sourceIndex,
    List<({int sourceIndex, VideoInfo video})> shortVideoEntries,
  ) async {
    if (!mounted) return;

    final orchestrator = PaymentOrchestrator(ref, context);
    await orchestrator.purchaseContentDirectly(
      contentType: 'video',
      contentId: video.id,
      price: video.price,
      contentTitle: video.title,
      onPurchased: () =>
          _handlePurchaseSuccess(video, sourceIndex, shortVideoEntries),
    );
  }

  Future<void> _showPricePopup(
    VideoInfo video,
    int sourceIndex,
    List<({int sourceIndex, VideoInfo video})> shortVideoEntries,
  ) async {
    final action = await PriceBottomSheet.show(
      context: context,
      ref: ref,
      video: video,
      contentId: video.id,
      contentType: 'video',
      onVipPurchased: () =>
          _handlePurchaseSuccess(video, sourceIndex, shortVideoEntries),
    );

    if (!mounted) return;

    switch (action) {
      case PriceBottomSheetAction.walletPayment:
        await _handleWalletPayment(video, sourceIndex, shortVideoEntries);
        break;
      case PriceBottomSheetAction.directPayment:
        await _handleDirectPayment(video, sourceIndex, shortVideoEntries);
        break;
      case PriceBottomSheetAction.dismissed:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Colors.white,
      onRefresh: () async => widget.onRefresh(),
      child: !widget.isLoaded
          ? _buildFirstLoading()
          : widget.loading && widget.results.isEmpty
          ? _buildFirstLoading()
          : NotificationListener<ScrollNotification>(
              onNotification: _handleScroll,
              child: widget.results.isEmpty ? _buildEmpty() : _buildVideoGrid(),
            ),
    );
  }

  Widget _buildFirstLoading() {
    return const Center(child: CircularProgressIndicator(color: Colors.white));
  }

  Widget _buildVideoGrid() {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    final results = widget.results;
    final shortVideoEntries = _shortVideoEntries(results);
    return CustomScrollView(
      key: widget.scrollStorageKey == null
          ? null
          : PageStorageKey<String>(widget.scrollStorageKey!),
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(6),
          sliver: SliverWaterfallFlow(
            gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (widget.loading && index == results.length) {
                  return _buildLoadMoreIndicator();
                }

                final video = results[index];
                final isPurchased = ref.watch(
                  isContentPurchasedProvider(('video', video.id)),
                );
                final hasPurchased = video.isBought || isPurchased;

                return LayoutBuilder(
                  builder: (ctx, constraints) {
                    final columnWidth = constraints.maxWidth;
                    final gridItem = VideoGridItem(
                      video: video,
                      knownHeight: 300,
                      heroTagPrefix: "search_grid",
                      index: index,
                      activeHeroIndex: _activeHeroIndex,
                      hasPurchased: hasPurchased,
                      purchasedLabel: i18n.translate("bought"),
                      onTapItem: (idx) async {
                        if (video.price == 0.0 ||
                            hasPurchased ||
                            ref.hasPermission(Permission.accessLongFree)) {
                          _openVideoDetail(video, idx, shortVideoEntries);
                          return;
                        }

                        await _showPricePopup(video, idx, shortVideoEntries);
                      },
                      onUserTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UserDetailPage(user: video.user),
                          ),
                        );
                      },
                      columnWidth: columnWidth,
                      hideUserInfo: widget.hideUserInfo,
                      preloadCoverUrls: _buildCoverPrefetchUrls(results, index),
                    );

                    if (widget.showDeleteButton && widget.onDelete != null) {
                      return Stack(
                        children: [
                          gridItem,
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => widget.onDelete!(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    return gridItem;
                  },
                );
              },
              childCount: results.length + (widget.loading ? 1 : 0),
              addAutomaticKeepAlives: false,
            ),
          ),
        ),
        if (widget.finished)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  i18n.translate('noMore'),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Center(child: EmptyWithRetry(onRetry: widget.onRefresh));
  }

  Widget _buildLoadMoreIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  bool _handleScroll(ScrollNotification scroll) {
    if (widget.isLoaded &&
        !widget.loading &&
        widget.results.isNotEmpty &&
        scroll.metrics.pixels >=
            scroll.metrics.maxScrollExtent - scroll.metrics.viewportDimension) {
      widget.onLoadMore();
    }
    return false;
  }
}
