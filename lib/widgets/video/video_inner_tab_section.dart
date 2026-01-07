import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/banner_provider.dart';
import 'package:live_app/widgets/video/video_list.dart';

import '../../models/sort_tab.dart';
import '../../models/video_info.dart';
import '../../provider/search_videos_provider.dart';
import '../banner_carousel.dart';

class VideoInnerTabSection extends ConsumerStatefulWidget {
  final int categoryId;
  final TabController outerController;
  final Map<int, String> sortTypeByCategory;
  final Function(VideoInfo videoInfo)? onUserTap;
  final int videoType;

  const VideoInnerTabSection({
    super.key,
    required this.categoryId,
    required this.outerController,
    required this.sortTypeByCategory,
    this.onUserTap,
    required this.videoType,
  });

  @override
  ConsumerState createState() => _VideoInnerTabSectionState();
}

class _VideoInnerTabSectionState extends ConsumerState<VideoInnerTabSection>
    with AutomaticKeepAliveClientMixin {
  bool _initialFetched = false;
  final Map<String, SearchVideoParams> _paramsCache = {};
  Locale? _lastLocale;

  SearchVideoParams _getParams(int categoryId, String sort, int type) {
    final key = '$categoryId-$sort-$type';
    return _paramsCache[key] ??= SearchVideoParams(
      categoryId: categoryId,
      sort: sort,
      typeId: type,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_initialFetched) return;
      _initialFetched = true;
      final categoryId = widget.categoryId;
      final currentSort = widget.sortTypeByCategory[categoryId] ?? 'latest';
      final typeId = widget.videoType;
      final params = _getParams(categoryId, currentSort, typeId);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(bannerListProvider.notifier).loadBanners(refresh: true);
        ref.read(searchVideosProvider(params).notifier).fetch(refresh: true);
      });
    });
  }

  @override
  void didUpdateWidget(VideoInnerTabSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoType != widget.videoType) {
      final currentSort =
          widget.sortTypeByCategory[widget.categoryId] ?? 'latest';
      final params = _getParams(
        widget.categoryId,
        currentSort,
        widget.videoType,
      );
      ref.invalidate(searchVideosProvider(params));

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(searchVideosProvider(params).notifier).fetch(refresh: true);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentLocale = Localizations.localeOf(context);

    if (_lastLocale != null && _lastLocale != currentLocale) {
      setState(() {});
    }
    _lastLocale = currentLocale;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final categoryId = widget.categoryId;
    final currentSort = widget.sortTypeByCategory[categoryId] ?? 'latest';

    return DefaultTabController(
      key: ValueKey(Localizations.localeOf(context).languageCode),
      length: getSortTabs(ref).length,
      initialIndex:
          getSortTabs(ref).indexWhere((t) => t.type == currentSort) >= 0
          ? getSortTabs(ref).indexWhere((t) => t.type == currentSort)
          : 0,
      child: Builder(
        builder: (context) {
          final tabController = DefaultTabController.of(context);

          Future<void> onRefresh() async {
            final params = _getParams(
              categoryId,
              getSortTabs(ref)[tabController.index].type,
              widget.videoType,
            );
            await ref
                .read(searchVideosProvider(params).notifier)
                .fetch(refresh: true);
          }

          tabController.addListener(() {
            if (!tabController.indexIsChanging) {
              final newType = getSortTabs(ref)[tabController.index].type;
              if (newType == widget.sortTypeByCategory[categoryId]) return;
              setState(() {
                widget.sortTypeByCategory[categoryId] = newType;
              });

              final params = _getParams(categoryId, newType, widget.videoType);
              ref
                  .read(searchVideosProvider(params).notifier)
                  .fetch(refresh: true);
            }
          });

          return NestedScrollView(
            headerSliverBuilder: (context, inner) {
              return [
                SliverToBoxAdapter(
                  child: Consumer(
                    builder: (context, ref, _) {
                      final bannerState = ref.watch(bannerListProvider);

                      if (bannerState.isLoading ||
                          bannerState.banners.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      final items = bannerState.banners
                          .map(
                            (b) => BannerItem(
                              img: b.urlImage,
                              action: b.id.toString(),
                            ),
                          )
                          .toList();

                      return SizedBox(
                        height: 160,
                        child: BannerCarousel(items: items),
                      );
                    },
                  ),
                ),

                SliverOverlapAbsorber(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                    context,
                  ),
                  sliver: SliverPersistentHeader(
                    pinned: true,
                    delegate: StickyTabBarDelegate(
                      child: Container(
                        color: Colors.black,
                        height: 48,
                        child: getSortTabBar(tabController, ref),
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: tabController,
              children: getSortTabs(ref).map((sortTab) {
                final params = _getParams(
                  categoryId,
                  sortTab.type,
                  widget.videoType,
                );
                final provider = searchVideosProvider(params);
                return Builder(
                  builder: (context) {
                    return NotificationListener<ScrollNotification>(
                      onNotification: (n) {
                        if (n is ScrollEndNotification) {
                          final m = n.metrics;
                          if (m.pixels >=
                              m.maxScrollExtent -
                                  MediaQuery.of(context).size.height * 2) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              ref.read(provider.notifier).fetch();
                            });
                          }
                        }
                        return false;
                      },
                      child: RefreshIndicator(
                        color: Colors.white,
                        backgroundColor: Colors.black,
                        strokeWidth: 2.0,
                        elevation: 0.0,
                        onRefresh: onRefresh,
                        child: CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          key: PageStorageKey(
                            'list-$categoryId-${sortTab.type}',
                          ),
                          slivers: [
                            SliverOverlapInjector(
                              handle:
                                  NestedScrollView.sliverOverlapAbsorberHandleFor(
                                    context,
                                  ),
                            ),
                            VideoListSliver(
                              provider: provider,
                              onRefresh: onRefresh,
                              onUserTap: widget.onUserTap,
                            ),
                            SliverToBoxAdapter(
                              child: SizedBox(
                                height: MediaQuery.of(context).padding.bottom,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  StickyTabBarDelegate({required this.child});

  @override
  double get minExtent => 48; // 最小高度
  @override
  double get maxExtent => 48; // 最大高度（与TabBar高度一致）

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
