import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/userinfo.dart';
import '../../models/video_list_state.dart';
import '../../page/short_video_detail_page.dart';
import '../../provider/user_videos_provider.dart';
import '../empty_retry.dart';
import '../encrypted_image.dart';

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
      return EmptyWithRetry(
        onRetry: () => notifier!.fetch(refresh: true),
      );
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
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                  childAspectRatio: 0.7,
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
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Hero(
                          tag: "video_${video.id}", // 保证 tag 唯一
                          placeholderBuilder: (context, heroSize, child) {
                            return child;
                          },
                          child: _activeHeroIndex == index
                              ? Container(color: Colors.transparent)
                              : EncryptedImage(
                                  url: video.cover,
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
                      ? const Text(
                    "没有更多了",
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
