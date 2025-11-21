import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/l10n/app_localizations.dart';
import 'package:waterfall_flow/waterfall_flow.dart';
import '../../models/video_info.dart';
import '../../models/video_list_state.dart';
import '../../page/short_video_detail_page.dart';
import '../../provider/home_video_list_provider.dart';
import '../../provider/cureent_video_user_provider.dart';
import '../empty_widget.dart';
import '../encrypted_image.dart';
import '../network_image_with_measure.dart';
import '../video/video_tag_category_wrap.dart';
import '../video/video_stat_item.dart';

class VideoGridTabView extends ConsumerStatefulWidget {
  final int filterType;
  final int videoType;
  final Function(VideoInfo videoInfo) onUserTap; // 新增：点击头像回调

  const VideoGridTabView({
    super.key,
    required this.videoType,
    required this.filterType,
    required this.onUserTap,
  });

  @override
  VideoGridViewState createState() => VideoGridViewState();
}

class VideoGridViewState extends ConsumerState<VideoGridTabView> {
  int? _activeHeroIndex;
  late final StateNotifierProvider<HomeVideoListNotifier, VideoListState>
  provider;
  late final HomeVideoListNotifier notifier;

  List<double?> _itemHeights = [];
  final ScrollController _scrollController = ScrollController();

  @override
  @override
  void initState() {
    super.initState();

    provider = homeVideoListProvider((widget.videoType, widget.filterType));
    notifier = ref.read(provider.notifier);
    _scrollController.addListener(_onScroll);
    Future.microtask(() => notifier.fetch(refresh: true));
  }

  void _onScroll() {
    // 安全判断：防止滚动到底触发多次
    final state = ref.read(provider);
    if (state.loading || state.finished) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 600) {
      notifier.fetch(refresh: false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(provider);
    _itemHeights = List<double?>.filled(state.list.length, 300);

    if (state.loading && state.list.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!state.loading && state.list.isEmpty) {
      return CustomScrollView(
        controller: _scrollController,
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.bottom -
                  MediaQuery.of(context).padding.top * 2 -
                  45,
              child: EmptyWidget(
                message: AppLocalizations.of(context)!.noVideoContent,
                icon: Icons.video_library_outlined,
              ),
            ),
          ),
        ],
      );
    }

    return WaterfallFlow.builder(
      controller: _scrollController,
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(5.0),
      gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 5.0,
        mainAxisSpacing: 5.0,
      ),

      itemCount: state.list.length,
      itemBuilder: (BuildContext context, int index) {
        final VideoInfo video = state.list[index];
        double? knownHeight = _itemHeights[index];

        final heroTagPrefix = "grid_${widget.filterType}";

        onUserTap() {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(currentUserProvider.notifier).state = video.user;
          });
          widget.onUserTap.call(video);
        }

        return LayoutBuilder(
          builder: (ctx, constraints) {
            // constraints.maxWidth 是 item 的列宽
            final double columnWidth = constraints.maxWidth;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: columnWidth,
                    height: knownHeight,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        setState(() {
                          _activeHeroIndex = index;
                        });
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            opaque: false,
                            barrierColor: Colors.transparent,
                            transitionDuration: const Duration(
                              milliseconds: 300,
                            ),
                            pageBuilder: (_, __, ___) => ShortVideoDetailPage(
                              heroTagPrefix: heroTagPrefix,
                              provider: provider,
                              initialIndex: index,
                              isUserDetailPop: true,
                              onPageChanged: (newIndex) {
                                setState(() {
                                  _activeHeroIndex = newIndex;
                                });

                                if (newIndex >=
                                        ref.watch(provider).list.length - 2 &&
                                    !state.loading &&
                                    !state.finished) {
                                  notifier.fetch();
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
                        ).then((e) {
                          setState(() {
                            _activeHeroIndex = null;
                          });
                        });
                      },
                      child: Stack(
                        children: [
                          Hero(
                            tag: "${heroTagPrefix}_${video.id}",
                            placeholderBuilder: (context, heroSize, child) {
                              return child;
                            },
                            child: _activeHeroIndex == index
                                ? Container(color: Colors.transparent)
                                : NetworkImageWithMeasure(
                                    imageUrl: video.cover,
                                    onImageMeasured: (h) {
                                      if (_itemHeights[index] != h) {
                                        _itemHeights[index] = h;
                                        if (mounted) {
                                          // 延迟批量刷新，而不是每次单独 setState()
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                                if (mounted) setState(() {});
                                              });
                                        }
                                      }
                                    },
                                  ),
                          ),

                          // 底部信息层
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.8),
                                    Colors.black.withValues(alpha: 0.4),
                                    Colors.transparent,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    blurRadius: 6,
                                    offset: const Offset(0, -2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // 标题，两行省略
                                  Text(
                                    video.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),

                                  // 用户信息
                                  GestureDetector(
                                    onTap: onUserTap,
                                    child: Row(
                                      children: [
                                        UserAvatar(
                                          userId: video.userId,
                                          url:
                                              video.user.avatar ??
                                              "https://i.pravatar.cc/350",
                                          nickname: video.user.nickname,
                                          size: 20,
                                          onTap: onUserTap,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            video.user.nickname ?? "",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 文字、覆盖层
                Container(
                  color: Colors.black.withValues(alpha: 0.4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 4,
                  ),
                  child: Column(
                    children: [
                      // 点赞 / 收藏 / 观看数量 / 评论数量
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          VideoStatItem(
                            icon: video.isLike
                                ? Icons.favorite
                                : Icons.favorite_border,
                            hasColor: video.isLike,
                            color: Colors.red,
                            count: video.likeCount,
                          ),
                          VideoStatItem(
                            icon: video.isFavorite
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            hasColor: video.isFavorite,
                            color: Colors.yellow,
                            count: video.favoriteCount,
                          ),
                          VideoStatItem(
                            icon: Icons.play_arrow_rounded,
                            count: video.viewCount,
                          ),
                          VideoStatItem(
                            icon: Icons.comment,
                            count: video.commentCount,
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),
                      // 标签 + 分类
                      VideoTagCategoryWrap(
                        tags: video.tags,
                        categories: video.categories,
                      ),

                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
