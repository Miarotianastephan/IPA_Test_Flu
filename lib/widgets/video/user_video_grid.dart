import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/video_info.dart';
import 'package:live_app/page/long_video_detail_page.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/provider/purchased_contents_provider.dart';
import 'package:live_app/widgets/video/adaptive_video_cover.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../../models/userinfo.dart';
import '../../models/video_list_state.dart';
import '../../page/short_video_detail_page.dart';
import '../../provider/user_videos_provider.dart';
import '../../services/payment_orchestrator.dart';
import '../../utils/utils.dart';
import '../empty_retry.dart';
import '../payment/price_bottom_sheet.dart';

class UserVideoGrid extends ConsumerStatefulWidget {
  final UserInfo user;

  const UserVideoGrid({super.key, required this.user});

  @override
  ConsumerState<UserVideoGrid> createState() {
    return UserVideoGridState();
  }
}

/// 用户视频网格组件
class UserVideoGridState extends ConsumerState<UserVideoGrid>
    with AutomaticKeepAliveClientMixin {
  int? _activeHeroIndex;
  StateNotifierProvider<UserVideoListNotifier, VideoListState>? provider;
  UserVideoListNotifier? notifier;

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
    if (shortVideoIndex == -1) return;

    setState(() {
      _activeHeroIndex = sourceIndex;
    });

    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) =>
            ShortVideoDetailPage(
              provider: provider,
              initialIndex: shortVideoIndex,
              isUserDetailPop: true,
              selectVideos: (state) => state.list
                  .whereType<VideoInfo>()
                  .where((item) => item.type == 1)
                  .toList(),
              onPageChanged: (newIndex) {
                if (newIndex >= shortVideoEntries.length - 2 &&
                    !ref.read(provider!).loading &&
                    !ref.read(provider!).finished) {
                  notifier!.fetch();
                }
              },
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ).then((_) {
      if (!mounted) return;
      setState(() {
        _activeHeroIndex = null;
      });
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
  void initState() {
    super.initState();
    provider = userVideoListProvider(widget.user.id);
    notifier = ref.read(provider!.notifier);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final state = ref.watch(provider!);
    final i18n = ref.read(i18nNotifierProvider.notifier);

    if (!state.loading && state.list.isEmpty) {
      return EmptyWithRetry(onRetry: () => notifier!.fetch(refresh: true));
    }

    final shortVideoEntries = _shortVideoEntries(state.list);

    return RefreshIndicator(
      backgroundColor: Colors.white,
      onRefresh: () async => notifier!.fetch(refresh: true),
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!state.loading &&
              !state.finished &&
              scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent -
                      scrollInfo.metrics.viewportDimension) {
            notifier!.fetch();
          }
          return false;
        },
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(4),
              sliver: SliverWaterfallFlow(
                gridDelegate:
                    SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final video = state.list[index];
                  final isPurchased = ref.watch(
                    isContentPurchasedProvider(('video', video.id)),
                  );
                  final hasPurchased = video.isBought || isPurchased;
                  final isUnlocked =
                      video.price == 0.0 ||
                      hasPurchased ||
                      ref.hasPermission(Permission.accessLongFree);

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      if (isUnlocked) {
                        _openVideoDetail(video, index, shortVideoEntries);
                        return;
                      }

                      await _showPricePopup(video, index, shortVideoEntries);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Stack(
                        children: [
                          Hero(
                            tag: "video_${video.id}", // 保证 tag 唯一
                            placeholderBuilder: (context, heroSize, child) {
                              return child;
                            },
                            child: _activeHeroIndex == index
                                ? Container(color: Colors.transparent)
                                : AdaptiveVideoCover(
                                    url: video.cover,
                                    videoType: video.type,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          if (hasPurchased)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black87,
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  i18n.translate("bought"),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          Positioned(
                            bottom: 6,
                            left: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.favorite,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${video.likeCount}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }, childCount: state.list.length),
              ),
            ),
            // 底部加载提示
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: state.loading
                      ? const CircularProgressIndicator()
                      : state.finished
                      ? Text(
                          i18n.translate("noMore"),
                          style: TextStyle(color: Colors.white),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
