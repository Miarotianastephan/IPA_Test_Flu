import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/userinfo.dart';
import 'package:live_app/page/gallery_page.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/provider/user_follow_provider.dart';
import 'package:live_app/widgets/follow_button.dart';
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
import 'chat_detail_page.dart';

class UserDetailPage extends ConsumerStatefulWidget {
  final UserInfo user;
  final TikTokScaffoldController? tkController;
  final VoidCallback? onBack;
  final Function(double x)? onBackSlide;
  final String? cover;

  const UserDetailPage({
    super.key,
    required this.user,
    this.tkController,
    this.onBack,
    this.onBackSlide,
    this.cover,
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
  bool _isBioExpanded = false;
  late String? _coverUrl;
  bool _isLoadingCover = true;

  @override
  void initState() {
    super.initState();

    _coverUrl = widget.user.cover;
    _isLoadingCover = _coverUrl == null;

    final param = UserDetailProviderParam(
      widget.user.id,
      initialUser: widget.user,
    );

    userProvider = userDetailProvider(param);
    videoProvider = userVideoListProvider(widget.user.id);
    postProvider = userPostListProvider(widget.user.id);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      ref
          .read(userFollowProvider(widget.user.id.toString()).notifier)
          .setFromBackend(
            isFollowed: widget.user.isFollowed,
            fansCount: widget.user.fansCount ?? 0,
            followCount: widget.user.followCount ?? 0,
          );

      final detail = await ref
          .read(userProvider.notifier)
          .loadUserDetail(widget.user.id);

      if (detail != null) {
        if (detail.cover != null && _coverUrl == null) {
          setState(() {
            _coverUrl = detail.cover!;
          });
        }
        ref
            .read(userFollowProvider(widget.user.id.toString()).notifier)
            .setFromBackend(
              isFollowed: detail.isFollowed,
              fansCount: detail.fansCount ?? 0,
              followCount: detail.followCount ?? 0,
            );
      }
      setState(() {
        _isLoadingCover = false;
      });

      ref.read(videoProvider.notifier).fetch(refresh: true);
      ref.read(postProvider.notifier).fetch(refresh: true);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoState = ref.watch(videoProvider);
    final i18n = ref.read(i18nNotifierProvider.notifier);
    final user = widget.user;
    final postState = ref.watch(postProvider);
    final follow = ref.watch(userFollowProvider(user.id.toString()));

    bool hasAvatar() {
      return !(user.avatar == null || user.avatar!.isEmpty);
    }

    bool hasCover() {
      return !(_coverUrl == null || _coverUrl!.isEmpty);
    }

    return VisibilityDetector(
      key: Key("user_detail_${widget.user.id}"),
      onVisibilityChanged: (info) {},
      child: DefaultTabController(
        length: 2,
        child: Stack(
          children: [
            Scaffold(
              backgroundColor: Colors.black,
              body: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverAppBar(
                    backgroundColor: Colors.black,
                    expandedHeight: _isBioExpanded ? 550 : 435,
                    floating: false,
                    pinned: true,
                    collapsedHeight: kToolbarHeight,
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
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatDetailPage(user: user),
                            ),
                          );
                        },
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
                                  height: 250,
                                  width: double.infinity,
                                  child: (_isLoadingCover)
                                      ? Container(
                                          color: Colors.grey[300],
                                          child: const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        )
                                      : (!hasCover())
                                      ? Container(
                                          color: Colors.grey[800],
                                          child: const Center(
                                            child: Icon(
                                              Icons.image_not_supported,
                                              color: Colors.white54,
                                              size: 60,
                                            ),
                                          ),
                                        )
                                      : GestureDetector(
                                          onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => GalleryPage(
                                                items: [
                                                  GalleryItem(
                                                    url: _coverUrl!,
                                                    isVideo: false,
                                                  ),
                                                ],
                                                initialIndex: 0,
                                              ),
                                            ),
                                          ),
                                          child: EncryptedImage(
                                            key: ValueKey<String>(_coverUrl!),
                                            url: _coverUrl!,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: 100,
                                            placeholder: Container(
                                              color: Colors.grey[300],
                                              child: const Center(
                                                child:
                                                    CircularProgressIndicator(),
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
                                ),
                              ],
                            ),
                            Transform.translate(
                              offset: const Offset(0, -40),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  SizedBox(width: 5),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: UserAvatar(
                                      url: user.avatar,
                                      nickname: user.nickname,
                                      size: 100,
                                      onTap: () => (!hasAvatar())
                                          ? null
                                          : Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => GalleryPage(
                                                  items: [
                                                    GalleryItem(
                                                      url: user.avatar!,
                                                      isVideo: false,
                                                    ),
                                                  ],
                                                  initialIndex: 0,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 10,
                                        right: 10,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                flex: 8,
                                                child: Text(
                                                  user.nickname ?? "",
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18.0,
                                                    fontWeight: FontWeight.bold,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                              const Spacer(),
                                              FollowButton(
                                                userId: user.id.toString(),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 6),

                                          Text(
                                            "id: ${user.displayId}",
                                            style: const TextStyle(
                                              color: Colors.white70,
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

                            Padding(
                              padding: const EdgeInsets.only(
                                left: 12,
                                right: 12,
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: _buildBioText(
                                  user.bio ?? i18n.translate('mysteriousUser'),
                                ),
                              ),
                            ),

                            const SizedBox(height: 15),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width < 375
                                    ? 16
                                    : 40,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildCountItem(
                                    i18n.translate('followCount'),
                                    follow
                                        .followCount, // plus besoin de fallback vers user.followCount
                                  ),
                                  _buildCountItem(
                                    i18n.translate('fansCount'),
                                    follow.fansCount, // idem
                                  ),
                                  _buildCountItem(
                                    i18n.translate('likeCount'),
                                    user.likeCount ??
                                        0, // likeCount toujours depuis user
                                  ),
                                ],
                              ),
                            ),
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
                                Text(i18n.translate('video')),
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
                                Text(i18n.translate('post')),
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
          ],
        ),
      ),
    );
  }

  Widget _buildBioText(String bioText) {
    final i18n = ref.read(i18nNotifierProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        const textStyle = TextStyle(color: Colors.white70, fontSize: 14);
        const maxLines = 2;

        final textSpan = TextSpan(text: bioText, style: textStyle);
        final textPainter = TextPainter(
          text: textSpan,
          maxLines: maxLines,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(maxWidth: constraints.maxWidth);

        final isTextOverflowing = textPainter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Stack(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: _isBioExpanded ? 150 : double.infinity,
                    ),
                    child: SingleChildScrollView(
                      physics: _isBioExpanded
                          ? const AlwaysScrollableScrollPhysics()
                          : const NeverScrollableScrollPhysics(),
                      child: Text(
                        bioText,
                        style: textStyle,
                        textAlign: TextAlign.start,
                        maxLines: _isBioExpanded ? null : maxLines,
                        overflow: _isBioExpanded ? null : TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (_isBioExpanded)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.0),
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (isTextOverflowing)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isBioExpanded = !_isBioExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _isBioExpanded
                        ? i18n.translate('showLess')
                        : "...${i18n.translate('seeMore')}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
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
