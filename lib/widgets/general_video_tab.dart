import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/video_info.dart';
import 'package:live_app/widgets/video/video_grid_item.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../page/short_video_detail_page.dart';
import '../page/user_detail_page.dart';
import 'empty_retry.dart';
import 'video/video_card.dart';

class GeneralVideoTab extends ConsumerStatefulWidget {
  final bool loading;
  final List<VideoInfo> results;
  final bool isLoaded;
  final bool isLongVideo;
  final VoidCallback onRefresh;
  final VoidCallback onLoadMore;
  final bool finished;
  final dynamic provider;

  const GeneralVideoTab({
    super.key,
    required this.loading,
    required this.results,
    required this.isLoaded,
    required this.isLongVideo,
    required this.onRefresh,
    required this.onLoadMore,
    required this.finished,
    required this.provider,
  });

  @override
  ConsumerState<GeneralVideoTab> createState() => _GeneralVideoTabState();
}

class _GeneralVideoTabState extends ConsumerState<GeneralVideoTab> {
  int? _activeHeroIndex;

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
              child: widget.results.isEmpty ? _buildEmpty() : _buildList(),
            ),
    );
  }

  Widget _buildFirstLoading() {
    return const Center(child: CircularProgressIndicator(color: Colors.white));
  }

  Widget _buildList() {
    return widget.isLongVideo ? _buildLongVideoList() : _buildShortVideoGrid();
  }

  Widget _buildShortVideoGrid() {
    return CustomScrollView(
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
            delegate: SliverChildBuilderDelegate((context, index) {
              if (widget.loading && index == widget.results.length) {
                return _buildLoadMoreIndicator();
              }

              final video = widget.results[index];

              return LayoutBuilder(
                builder: (ctx, constraints) {
                  // constraints.maxWidth 是 item 的列宽
                  final double columnWidth = constraints.maxWidth;
                  return VideoGridItem(
                    video: video,
                    knownHeight: 300,
                    heroTagPrefix: "search_grid",
                    index: index,
                    activeHeroIndex: _activeHeroIndex,
                    onTapItem: (idx) {
                      setState(() => _activeHeroIndex = idx);
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          opaque: false,
                          barrierColor: Colors.transparent,
                          transitionDuration: const Duration(milliseconds: 300),
                          pageBuilder: (_, __, ___) => ShortVideoDetailPage(
                            heroTagPrefix: "search_grid",
                            initialIndex: idx,
                            isUserDetailPop: true,
                            provider: widget.provider,
                            onPageChanged: (newIndex) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) {
                                  setState(() {
                                    _activeHeroIndex = newIndex;
                                  });
                                }
                              });

                              if (newIndex > widget.results.length - 2 &&
                                  !widget.loading &&
                                  !widget.finished) {
                                widget.onLoadMore();
                              }
                            },
                          ),
                          transitionsBuilder: (_, animation, __, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                        ),
                      ).then((_) {
                        if (mounted) setState(() => _activeHeroIndex = null);
                      });
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
                    onMeasured: (_) {},
                    columnWidth: columnWidth,
                  );
                },
              );
            }, childCount: widget.results.length + (widget.loading ? 1 : 0)),
          ),
        ),
        if (widget.finished)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text("没有更多了", style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLongVideoList() {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: .95,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            // 最后一项显示正在加载更多
            if (widget.loading && index == widget.results.length) {
              return _buildLoadMoreIndicator();
            }

            final video = widget.results[index];
            return VideoCard(video: video);
          }, childCount: widget.results.length + (widget.loading ? 1 : 0)),
        ),
        if (widget.finished)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text("没有更多了", style: TextStyle(color: Colors.white)),
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
