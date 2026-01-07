import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/widgets/video/adaptive_video_cover.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../../models/userinfo.dart';
import '../../models/video_list_state.dart';
import '../../page/short_video_detail_page.dart';
import '../../provider/user_videos_provider.dart';
import '../empty_retry.dart';

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
  // late final StateNotifierProvider<UserVideoListNotifier, VideoListState> provider;
  // late final UserVideoListNotifier notifier;
  StateNotifierProvider<UserVideoListNotifier, VideoListState>? provider;
  UserVideoListNotifier? notifier;
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

    if (!state.loading && state.list.isEmpty) {
      return EmptyWithRetry(onRetry: () => notifier!.fetch(refresh: true));
    }

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
                    const SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final video = state.list[index];
                  return GestureDetector(
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
                          transitionDuration: const Duration(milliseconds: 300),
                          pageBuilder: (_, __, ___) => ShortVideoDetailPage(
                            provider: provider,
                            initialIndex: index,
                            onPageChanged: (newIndex) {
                              setState(() {
                                _activeHeroIndex = newIndex;
                              });

                              if (newIndex >=
                                      ref.watch(provider!).list.length - 2 &&
                                  !state.loading &&
                                  !state.finished) {
                                notifier!.fetch();
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
                          ref
                              .read(i18nNotifierProvider.notifier)
                              .translate("noMore"),
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
