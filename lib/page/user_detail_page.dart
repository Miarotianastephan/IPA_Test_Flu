import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/l10n/app_localizations.dart';
import 'package:live_app/models/userinfo.dart';
import 'package:live_app/widgets/tiktok_scaffold.dart';
import 'package:live_app/widgets/video/user_post_list.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../models/base_list_state.dart';
import '../models/forum_post.dart';
import '../models/video_list_state.dart';
import '../provider/user_detail_provider.dart';
import '../provider/user_post_list_provider.dart';
import '../provider/user_videos_provider.dart';
import '../widgets/encrypted_image.dart';
import '../widgets/video/user_video_grid.dart';

class UserDetailPage extends ConsumerStatefulWidget {
  final UserInfo user;
  final TikTokScaffoldController? tkController;
  final VoidCallback? onBack;
  final Function(double x)? onBackSlide;

  const UserDetailPage({
    super.key,
    required this.user,
    this.tkController,
    this.onBack,
    this.onBackSlide,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return UserDetailPageState();
  }
}

class UserDetailPageState extends ConsumerState<UserDetailPage> {
  late final StateNotifierProvider<UserDetailNotifier, UserDetailState>
  userProvider;
  late final StateNotifierProvider<
    UserPostListNotifier,
    BaseListState<ForumPost>
  >
  postProvider;
  late final StateNotifierProvider<UserVideoListNotifier, VideoListState>
  videoProvider;
  double _dragAccumulatedX = 0.0;

  @override
  void initState() {
    super.initState();
    // 使用 userDetailProvider 管理用户信息
    userProvider = userDetailProvider(widget.user.id);
    videoProvider = userVideoListProvider(widget.user.id);
    postProvider = userPostListProvider(widget.user.id);

    // 加载帖子 & 视频
    ref.read(videoProvider.notifier).fetch(refresh: true);
    ref.read(postProvider.notifier).fetch(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final videoState = ref.watch(videoProvider);
    final localizations = AppLocalizations.of(context)!;
    final user = userState.user ?? widget.user;
    final postState = ref.watch(postProvider);

    return VisibilityDetector(
      key: Key("user_detail_${widget.user.id}"),
      onVisibilityChanged: (info) {
        if (info.visibleFraction == 1) {
          ref.read(userProvider.notifier).loadUserDetail(widget.user.id);
          ref.read(videoProvider.notifier).fetch(refresh: true);
        }
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                backgroundColor: Colors.black,
                expandedHeight: 443,
                floating: false,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => {
                    if (widget.tkController != null)
                      {widget.tkController?.animateToMiddle()}
                    else if (widget.onBack != null)
                      {widget.onBack!.call()}
                    else
                      {Navigator.of(context).pop()},
                  },
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.more_horiz, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
                title: LayoutBuilder(
                  builder: (context, constraints) {
                    final settings = context
                        .dependOnInheritedWidgetOfExactType<
                          FlexibleSpaceBarSettings
                        >();
                    final collapsed =
                        settings != null &&
                        settings.currentExtent <= settings.minExtent + 20;
                    return AnimatedOpacity(
                      opacity: collapsed ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Row(
                        children: [
                          UserAvatar(
                            url: user.avatar,
                            nickname: user.nickname,
                            size: 28,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            user.nickname ?? "",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            SizedBox(
                              height: 185,
                              width: double.infinity,
                              child: EncryptedImage(
                                url: user.cover ?? "https://i.pravatar.cc/350",
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 200,
                                placeholder: Container(
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: Container(
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(Icons.broken_image),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -50,
                              left: 0,
                              right: 0,
                              child: Align(
                                alignment: Alignment.center,
                                child: UserAvatar(
                                  url:
                                      user.avatar ??
                                      "https://i.pravatar.cc/350",
                                  nickname: user.nickname,
                                  size: 110,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 55),
                        Text(
                          user.nickname ?? "",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "${user.displayId}",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user.bio ?? localizations.mysteriousUser,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width < 375
                                ? 16
                                : 40,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildCountItem(
                                localizations.followCount,
                                user.followCount ?? 0,
                              ),
                              _buildCountItem(
                                localizations.fansCount,
                                user.fansCount ?? 0,
                              ),
                              _buildCountItem(
                                localizations.likeCount,
                                user.likeCount ?? 0,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // 按钮区域，关注按钮联动 provider
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width < 375
                                ? 16
                                : 40,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Container(
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: user.isFollowed
                                        ? Colors.grey[400]
                                        : Colors.red,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: TextButton(
                                    onPressed: () async {
                                      await ref
                                          .read(userProvider.notifier)
                                          .toggleFollow();
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ),
                                    child: Text(
                                      user.isFollowed
                                          ? localizations.followed
                                          : localizations.follow,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width < 375
                                    ? 8
                                    : 12,
                              ),
                              Container(
                                height: 36,
                                width: MediaQuery.of(context).size.width < 375
                                    ? 60
                                    : 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade800,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.more_horiz,
                                    color: Colors.white,
                                  ),
                                  padding: EdgeInsets.zero,
                                  iconSize: 20,
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width < 375
                                    ? 8
                                    : 12,
                              ),
                              Container(
                                height: 36,
                                width: 36,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade800,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.message,
                                    color: Colors.white,
                                  ),
                                  padding: EdgeInsets.zero,
                                  iconSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  videoState.total,
                  TabBar(
                    indicatorColor: Colors.white,
                    indicatorWeight: 2,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white54,
                    labelPadding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width < 375
                          ? 16
                          : 30,
                    ),
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(localizations.video),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "${videoState.total}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(localizations.post),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "${postState.total}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
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
            body: Stack(
              children: [
                TabBarView(
                  physics: const ClampingScrollPhysics(),
                  children: [
                    UserVideoGrid(user: user),
                    UserPostList(user: user),
                  ],
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 60,
                  // 手势返回区域宽度
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onHorizontalDragStart: (_) {
                      _dragAccumulatedX = 0.0; // 每次开始清零
                    },

                    onHorizontalDragUpdate: (details) {
                      _dragAccumulatedX += details.delta.dx;
                      if (widget.tkController != null) {
                        widget.tkController!.animateToX(details.delta.dx);
                        return;
                      }

                      if (widget.onBackSlide != null) {
                        widget.onBackSlide?.call(details.delta.dx);
                        return;
                      }
                    },
                    onHorizontalDragEnd: (details) {
                      final velocity = details.velocity.pixelsPerSecond.dx;
                      final screenWidth = MediaQuery.of(context).size.width;

                      // 右滑速度足够快 或 滑动超过 1/3 屏宽 => 返回 middle
                      if (velocity > 400 ||
                          _dragAccumulatedX > screenWidth / 3) {
                        if (widget.tkController != null) {
                          widget.tkController!.animateToMiddle();
                        }

                        if (widget.onBack != null) {
                          widget.onBack?.call();
                        }
                      } else {
                        // 否则恢复到右页位置
                        if (widget.tkController != null) {
                          widget.tkController!.animateToRight();
                        }

                        if (widget.onBackSlide != null) {}
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountItem(String label, int count) {
    return Column(
      children: [
        Text(
          "$count",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  final int itemCount;

  _SliverAppBarDelegate(this.itemCount, this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.black, child: _tabBar);
  }

  @override
  bool shouldRebuild(covariant _SliverAppBarDelegate oldDelegate) {
    return oldDelegate.itemCount != itemCount; // 只在数量变化时 rebuild
  }
}
