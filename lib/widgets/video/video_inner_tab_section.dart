import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  const VideoInnerTabSection({
    super.key,
    required this.categoryId,
    required this.outerController,
    required this.sortTypeByCategory,
    this.onUserTap,
  });

  @override
  ConsumerState createState() => _VideoInnerTabSectionState();
}

class _VideoInnerTabSectionState extends ConsumerState<VideoInnerTabSection>
    with AutomaticKeepAliveClientMixin {
  bool _initialFetched = false;
  final Map<String, SearchVideoParams> _paramsCache = {};

  SearchVideoParams _getParams(int categoryId, String sort) {
    final key = '$categoryId-$sort';
    return _paramsCache[key] ??= SearchVideoParams(
      categoryId: categoryId,
      sort: sort,
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
      final params = _getParams(categoryId, currentSort);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(searchVideosProvider(params).notifier).fetch(refresh: true);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final categoryId = widget.categoryId;
    final currentSort = widget.sortTypeByCategory[categoryId] ?? 'latest';

    return DefaultTabController(
      length: getSortTabs(context).length,
      initialIndex:
          getSortTabs(context).indexWhere((t) => t.type == currentSort) >= 0
          ? getSortTabs(context).indexWhere((t) => t.type == currentSort)
          : 0,
      child: Builder(
        builder: (context) {
          final tabController = DefaultTabController.of(context);

          Future<void> onRefresh() async {
            final params = _getParams(
              categoryId,
              getSortTabs(context)[tabController.index].type,
            );
            await ref
                .read(searchVideosProvider(params).notifier)
                .fetch(refresh: true);
          }

          tabController.addListener(() {
            if (!tabController.indexIsChanging) {
              final newType = getSortTabs(context)[tabController.index].type;
              if (newType == widget.sortTypeByCategory[categoryId]) return;
              setState(() {
                widget.sortTypeByCategory[categoryId] = newType;
              });
              // fetch on sort switch
              final params = _getParams(categoryId, newType);
              ref
                  .read(searchVideosProvider(params).notifier)
                  .fetch(refresh: true);
            }
          });

          return NestedScrollView(
            headerSliverBuilder: (context, inner) {
              return [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 160,
                    child: BannerCarousel(
                      items: [
                        BannerItem(
                          img: 'https://picsum.photos/400/160?random=0',
                          action: "1",
                        ),
                        BannerItem(
                          img: 'https://picsum.photos/400/160?random=1',
                          action: "1",
                        ),
                        BannerItem(
                          img: 'https://picsum.photos/400/160?random=2',
                          action: "1",
                        ),
                      ],
                    ),
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
                        child: getSortTabBar(context, tabController),
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: tabController,
              children: getSortTabs(context).map((sortTab) {
                final params = _getParams(categoryId, sortTab.type);
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
                        onRefresh: onRefresh,
                        child: CustomScrollView(
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
