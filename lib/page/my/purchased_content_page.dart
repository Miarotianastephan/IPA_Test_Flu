import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../../models/content_bought.dart';
import '../../models/video_info.dart';
import '../../page/forum_post_detail_page.dart';
import '../../page/long_video_detail_page.dart';
import '../../page/short_video_detail_page.dart';
import '../../provider/i18n_provider.dart';
import '../../provider/my_purchased_provider.dart';
import '../../provider/purchased_video_provider.dart';
import '../../widgets/video/adaptive_video_cover.dart';

class PurchasedContentPage extends ConsumerStatefulWidget {
  const PurchasedContentPage({super.key});

  @override
  ConsumerState<PurchasedContentPage> createState() =>
      _PurchasedContentPageState();
}

class _PurchasedContentPageState extends ConsumerState<PurchasedContentPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<({String type, String labelKey, IconData icon})> _tabs = [
    (type: 'video', labelKey: 'videos', icon: Icons.video_library),
    // (type: 'audio', labelKey: 'audio', icon: Icons.audiotrack),
    (type: 'posts', labelKey: 'mangas', icon: Icons.article),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String translate(String key) =>
      ref.read(i18nNotifierProvider.notifier).translate(key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(translate('myPurchases')),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelPadding: const EdgeInsets.symmetric(horizontal: 12),
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: _tabs
              .map(
                (tab) => Tab(
                  icon: Icon(tab.icon, size: 20),
                  text: translate(tab.labelKey),
                ),
              )
              .toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs
            .map((tab) => _PurchasedContentList(type: tab.type))
            .toList(),
      ),
    );
  }
}

class _PurchasedContentList extends ConsumerStatefulWidget {
  final String type;

  const _PurchasedContentList({required this.type});

  @override
  ConsumerState<_PurchasedContentList> createState() =>
      _PurchasedContentListState();
}

class _PurchasedContentListState extends ConsumerState<_PurchasedContentList>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  int? _activeHeroIndex;

  List<({int sourceIndex, VideoInfo video})> _shortVideoEntries(
    List<VideoInfo> videos,
  ) {
    return [
      for (int i = 0; i < videos.length; i++)
        if (videos[i].type == 1) (sourceIndex: i, video: videos[i]),
    ];
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
              provider: purchasedVideoProvider,
              initialIndex: shortVideoIndex,
              selectVideos: (state) => state.list
                  .whereType<VideoInfo>()
                  .where((item) => item.type == 1)
                  .toList(),
              onPageChanged: (newIndex) {
                if (newIndex >= 0 && newIndex < shortVideoEntries.length) {
                  setState(() {
                    _activeHeroIndex = shortVideoEntries[newIndex].sourceIndex;
                  });
                }
                if (newIndex >= shortVideoEntries.length - 2 &&
                    !ref.read(purchasedVideoProvider).loading &&
                    !ref.read(purchasedVideoProvider).finished) {
                  ref.read(purchasedVideoProvider.notifier).fetch();
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

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (widget.type == 'video') {
      final state = ref.read(purchasedVideoProvider);
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.8 &&
          !state.finished &&
          !state.loading) {
        ref.read(purchasedVideoProvider.notifier).fetch();
      }
    } else {
      final state = ref.read(myPurchasedProvider(widget.type));
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.8 &&
          state.hasMore &&
          !state.isLoading) {
        ref.read(myPurchasedProvider(widget.type).notifier).loadPurchases();
      }
    }
  }

  String translate(String key) =>
      ref.read(i18nNotifierProvider.notifier).translate(key);

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.type == 'video') {
      return _buildVideoList();
    }

    final state = ref.watch(myPurchasedProvider(widget.type));
    final purchases = state.list;
    final isLoading = state.isLoading;

    if (state.error != null && purchases.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              translate('errorLoadingPurchases'),
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              onPressed: () => ref
                  .read(myPurchasedProvider(widget.type).notifier)
                  .loadPurchases(refresh: true),
              child: Text(translate('retry')),
            ),
          ],
        ),
      );
    }

    if (purchases.isEmpty && isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (purchases.isEmpty && !isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              translate('noPurchases'),
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref
          .read(myPurchasedProvider(widget.type).notifier)
          .loadPurchases(refresh: true),
      color: Colors.white,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: purchases.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == purchases.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          }

          final purchase = purchases[index];
          return _PurchaseItem(
            purchase: purchase,
            onTap: () {
              final postId = purchase.post?.id ?? purchase.typeIdAsInt;
              if (postId <= 0) return;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ForumPostDetailPage(postId: postId),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildVideoList() {
    final state = ref.watch(purchasedVideoProvider);
    final videos = state.list;
    final isLoading = state.loading;
    final notifier = ref.read(purchasedVideoProvider.notifier);
    final shortVideoEntries = _shortVideoEntries(videos);

    if (videos.isEmpty && isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (videos.isEmpty && !isLoading && !state.finished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.fetch(refresh: true);
      });
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (videos.isEmpty && state.finished) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              translate('noPurchases'),
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => notifier.fetch(refresh: true),
      color: Colors.white,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(4),
            sliver: SliverWaterfallFlow(
              gridDelegate:
                  const SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final video = videos[index];
                return _buildVideoItem(video, index, shortVideoEntries);
              }, childCount: videos.length),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: state.loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : state.finished
                    ? Text(
                        translate('noMore'),
                        style: const TextStyle(color: Colors.white),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoItem(
    VideoInfo video,
    int index,
    List<({int sourceIndex, VideoInfo video})> shortVideoEntries,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _openVideoDetail(video, index, shortVideoEntries);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          children: [
            Hero(
              tag: "video_${video.id}",
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
            Positioned(
              bottom: 6,
              left: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      "${video.likeCount}",
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PurchaseItem extends ConsumerWidget {
  final ContentBought purchase;
  final VoidCallback onTap;

  const _PurchaseItem({required this.purchase, required this.onTap});

  String translate(BuildContext context, WidgetRef ref, String key) =>
      ref.read(i18nNotifierProvider.notifier).translate(key);

  IconData _getContentIcon() {
    switch (purchase.type) {
      case 'video':
        return Icons.video_library;
      case 'audio':
        return Icons.audiotrack;
      case 'post':
      case 'posts':
        return Icons.article;
      default:
        return Icons.description;
    }
  }

  String _getContentLabelKey() {
    switch (purchase.type) {
      case 'post':
      case 'posts':
        return 'mangas';
      default:
        return purchase.type;
    }
  }

  String _getTitle(BuildContext context, WidgetRef ref) {
    switch (purchase.type) {
      case 'post':
      case 'posts':
        final title = purchase.post?.title.trim();
        if (title != null && title.isNotEmpty) {
          return title;
        }
        return '${translate(context, ref, _getContentLabelKey())} #${purchase.typeIdAsInt}';
      case 'video':
        final title = purchase.video?.title.trim();
        if (title != null && title.isNotEmpty) {
          return title;
        }
        return '${translate(context, ref, _getContentLabelKey())} #${purchase.video?.id ?? purchase.typeIdAsInt}';
      default:
        return '${translate(context, ref, _getContentLabelKey())} #${purchase.typeIdAsInt}';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getContentIcon(),
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTitle(context, ref),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormat.format(purchase.boughtAt),
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '\$${purchase.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
