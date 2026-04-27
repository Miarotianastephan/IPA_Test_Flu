import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/config/storage_config.dart';
import 'package:live_app/models/userinfo.dart';
import 'package:live_app/page/campaign/campaign_page.dart';
import 'package:live_app/page/gallery_page.dart';
import 'package:live_app/page/login/login_with_username.dart';
import 'package:live_app/page/my/Invitation_to_share_page.dart';
import 'package:live_app/page/my/my_fans_page.dart';
import 'package:live_app/page/my/my_follow_page.dart';
import 'package:live_app/page/my/user_info_page.dart';
import 'package:live_app/page/my/wallet_page.dart';
import 'package:live_app/provider/current_tab_provider.dart';
import 'package:live_app/provider/current_user_provider.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/provider/user_follow_provider.dart';
import 'package:live_app/utils/app_lang_version_utils.dart';
import 'package:live_app/widgets/auto_scroll_text.dart';
import 'package:live_app/widgets/tiktok_scaffold.dart';
import 'package:live_app/widgets/upgrade_plan_button.dart';
import 'package:live_app/widgets/vip_badge.dart';
import 'package:live_app/widgets/profile/account_credentials_dialog.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../models/base_list_state.dart';
import '../models/forum_post.dart';
import '../models/video_list_state.dart';
import '../provider/user_post_list_provider.dart';
import '../provider/user_videos_provider.dart';
import '../widgets/encrypted_image.dart';
import '../widgets/profile/profile_tab_content.dart';

class UserProfilePage extends ConsumerStatefulWidget {
  final UserInfo user;
  final TikTokScaffoldController? tkController;
  final VoidCallback? onBack;
  final Function(double x)? onBackSlide;
  final String? cover;
  final VoidCallback? onShowSettings;

  const UserProfilePage({
    super.key,
    required this.user,
    this.tkController,
    this.onBack,
    this.onBackSlide,
    this.cover,
    this.onShowSettings,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return UserProfilePageState();
  }
}

class UserProfilePageState extends ConsumerState<UserProfilePage>
    with TickerProviderStateMixin {
  late final ProviderContainer _container;
  late StateNotifierProvider<UserPostListNotifier, BaseListState<ForumPost>>
  postProvider;
  late StateNotifierProvider<UserVideoListNotifier, VideoListState>
  videoProvider;
  double _dragAccumulatedX = 0.0;
  bool _isBioExpanded = false;
  late String? _coverUrl;
  bool _isLoadingCover = true;
  bool _isLoggingOut = false;
  bool _isRefreshingUserData = false;
  bool _isPageVisible = false;
  bool _hasAutoShownCredentialsDialog = false;
  bool _isCheckingCredentialsDialog = false;
  late UserInfo _user;
  ProviderSubscription<int?>? _profileTabSectionSub;
  ProviderSubscription<int>? _currentTabIndexSub;
  ProviderSubscription<UserInfo?>? _currentUserSub;
  late TabController _tabController;

  int get _profileTabLength => kIsWeb ? 5 : 6;

  @override
  void initState() {
    super.initState();
    _container = ProviderScope.containerOf(context, listen: false);

    _user = widget.user;
    _coverUrl = _user.cover;
    _isLoadingCover = _coverUrl == null;

    _bindContentProviders(_user);

    _tabController = TabController(length: _profileTabLength, vsync: this);

    _profileTabSectionSub = ref.listenManual<int?>(profileTabSectionProvider, (
      _,
      tabIndex,
    ) {
      if (tabIndex == null) return;
      final target = tabIndex.clamp(0, _tabController.length - 1);
      _tabController.animateTo(target);
      _container.read(profileTabSectionProvider.notifier).state = null;
    });

    _currentTabIndexSub = ref.listenManual<int>(currentTabIndexProvider, (
      previous,
      next,
    ) {
      final profileTabIndex = _container.read(profileTabIndexProvider);
      if (profileTabIndex < 0) return;
      if (next == profileTabIndex && previous != next) {
        _refreshUserData();
      }
    });

    _currentUserSub = ref.listenManual<UserInfo?>(currentUserProvider, (
      previous,
      next,
    ) {
      if (next == null || !mounted) return;

      final userChanged = next.id != _user.id;
      setState(() {
        if (userChanged) {
          _bindContentProviders(next);
        }
        _applyUserData(next);
      });
      _scheduleFollowStateSync(next);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _applyUserData(_user);
      _scheduleFollowStateSync(_user);
      await _refreshUserData(refreshLists: true);
    });
  }

  @override
  void dispose() {
    _profileTabSectionSub?.close();
    _currentTabIndexSub?.close();
    _currentUserSub?.close();
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant UserProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final sameUserId = oldWidget.user.id == widget.user.id;

    setState(() {
      if (!sameUserId) {
        _bindContentProviders(widget.user);
      }
      _applyUserData(widget.user);
    });
    _scheduleFollowStateSync(widget.user);

    if (!sameUserId) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await _refreshUserData(refreshLists: true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final videoState = ref.watch(videoProvider);
    final i18n = ref.read(i18nNotifierProvider.notifier);
    final user = _user;
    final follow = ref.watch(userFollowProvider(user.id));
    final currentUserId = ref.watch(currentUserIdProvider);
    final showDownloadedTab = !kIsWeb;
    final tabWidgets = <Widget>[
      const Tab(child: Icon(Icons.widgets_outlined)),
      const Tab(child: Icon(Icons.favorite_outline)),
      const Tab(child: Icon(Icons.bookmark_outline)),
      const Tab(child: Icon(Icons.history)),
      const Tab(child: Icon(Icons.shopping_bag_outlined)),
      if (showDownloadedTab)
        const Tab(child: Icon(Icons.download_for_offline_outlined)),
    ];
    final currentUserTabViews = <Widget>[
      const ContentLiked(),
      const MyFavorite(),
      const WatchHistory(),
      const PurchasedContent(),
      if (showDownloadedTab) const DownloadedContent(),
    ];
    final otherUserTabViews = List<Widget>.filled(
      currentUserTabViews.length,
      const SizedBox.shrink(),
    );
    final tabViews = <Widget>[
      ContentUser(user: user),
      ...(currentUserId == user.id ? currentUserTabViews : otherUserTabViews),
    ];
    bool hasAvatar() {
      return !(user.avatar == null || user.avatar!.isEmpty);
    }

    bool hasCover() {
      return !(_coverUrl == null || _coverUrl!.isEmpty);
    }

    return VisibilityDetector(
      key: Key("user_detail_${_user.id}"),
      onVisibilityChanged: (info) {
        final isVisible = info.visibleFraction > 0.9;
        if (isVisible && !_isPageVisible) {
          _isPageVisible = true;
          _refreshUserData();
          _maybeShowCredentialsDialogOnce();
        } else if (!isVisible && _isPageVisible) {
          _isPageVisible = false;
        }
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.black,
            extendBody: true,
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  backgroundColor: Colors.black,
                  expandedHeight: _isBioExpanded
                      ? 550
                      : kIsWeb
                      ? 420
                      : 400,
                  floating: false,
                  pinned: true,
                  collapsedHeight: kToolbarHeight,
                  actions: [
                    IconButton(
                      icon: Icon(Icons.share),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const InvitationToSharePage(),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: _user.isVisitor
                          ? Icon(Icons.login)
                          : Icon(
                              Icons.logout,
                              color: const Color.fromARGB(255, 255, 94, 94),
                            ),
                      onPressed: _isLoggingOut
                          ? null
                          : () async {
                              if (_user.isVisitor) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const LoginWithUsernamePage(),
                                  ),
                                );
                              } else {
                                setState(() {
                                  _isLoggingOut = true;
                                });
                                try {
                                  await ref
                                      .read(currentUserProvider.notifier)
                                      .logout(cleanCache: true);
                                  final visitorUser = ref.read(
                                    currentUserProvider,
                                  );
                                  if (visitorUser != null) {
                                    setState(() {
                                      _bindContentProviders(visitorUser);
                                      _applyUserData(visitorUser);
                                    });
                                    _scheduleFollowStateSync(visitorUser);
                                    await _refreshUserData(refreshLists: true);
                                  }
                                } finally {
                                  setState(() {
                                    _isLoggingOut = false;
                                  });
                                }
                              }
                            },
                    ),

                    IconButton(
                      onPressed: widget.onShowSettings,
                      icon: Icon(Icons.more_vert),
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
                            Flexible(
                              child: AutoScrollText(
                                text: user.nickname ?? "",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            VipBadge(vip: user.vip, size: 16),
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
                            alignment: Alignment.bottomCenter,
                            children: [
                              SizedBox(
                                height: 180,
                                width: double.infinity,
                                child: (_isLoadingCover)
                                    ? Container(
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      )
                                    : (!hasCover())
                                    ? EncryptedImage(
                                        url:
                                            'https://lldvod.xosp.tv/images/c2404fc94ef675a6f2e2680507cde966f0f5f8bbc1159a850ccb911e1c01d91a.jpg',
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                        placeholder: Container(
                                          color: Colors.grey[300],
                                          child: const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                        errorWidget: Container(
                                          color: Colors.grey[800],
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
                                          height: double.infinity,
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
                              Positioned(
                                bottom: -50,
                                child: SizedBox(
                                  height: 110,
                                  width: 110,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: 104,
                                        height: 104,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.black,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.15,
                                              ),
                                              blurRadius: 12,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                      ),

                                      UserAvatar(
                                        url: user.avatar,
                                        nickname: user.nickname,
                                        size: 96,
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

                                      user.vip != null
                                          ? Positioned(
                                              bottom: 5,
                                              right: -2,
                                              child: SizedBox(
                                                width: 34,
                                                height: 34,
                                                child: OverflowBox(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  minWidth: 34,
                                                  maxWidth: 120,
                                                  child: SizedBox(
                                                    width: 86,
                                                    height: 34,
                                                    child: Stack(
                                                      clipBehavior: Clip.none,
                                                      children: [
                                                        Positioned(
                                                          left: 12,
                                                          bottom: 3,
                                                          child: Container(
                                                            height: 20,
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            padding:
                                                                const EdgeInsets.only(
                                                                  left: 24,
                                                                  right: 9,
                                                                ),
                                                            decoration:
                                                                BoxDecoration(
                                                                  color: Colors
                                                                      .amber,
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        999,
                                                                      ),
                                                                ),
                                                            child: const Text(
                                                              'VIP',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 11,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                height: 1,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Stack(
                                                          alignment:
                                                              Alignment.center,
                                                          children: [
                                                            Container(
                                                              width: 34,
                                                              height: 34,
                                                              decoration:
                                                                  const BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                            ),
                                                            VipBadge(
                                                              vip: user.vip,
                                                              size: 30,
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : const SizedBox.shrink(),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 50),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(width: 24),
                                Flexible(
                                  child: AutoScrollText(
                                    text: user.nickname ?? "",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UserInfoPage(
                                          user: user,
                                          editMode: true,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.only(left: 6),
                                    child: Icon(
                                      Icons.edit,
                                      color: Colors.white54,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "ID: ${user.displayId}",
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 13,
                                ),
                              ),
                              if (currentUserId == user.id) ...[
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: _showCredentialsDialog,
                                  child: const Icon(
                                    Icons.key,
                                    color: Colors.white54,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (user.vip != null) ...[
                            const SizedBox(height: 8),
                            _buildVipDurationChip(
                              user.vip!.validDays,
                              i18n.translate('days'),
                            ),
                          ],
                          const SizedBox(height: 14),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildCountItem(
                                i18n.translate('followCount'),
                                follow.followCount,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const MyFollowPage(),
                                    ),
                                  );
                                },
                              ),
                              Container(
                                width: 1,
                                height: 20,
                                color: Colors.white24,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                              ),
                              _buildCountItem(
                                i18n.translate('fansCount'),
                                follow.fansCount,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const MyFansPage(),
                                    ),
                                  );
                                },
                              ),
                              Container(
                                width: 1,
                                height: 20,
                                color: Colors.white24,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                              ),
                              _buildCountItem(
                                i18n.translate('likeCount'),
                                user.likeCount ?? 0,
                              ),
                            ],
                          ),
                          if (user.bio != null && user.bio!.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                              ),
                              child: _buildBioText(
                                user.bio ?? i18n.translate('mysteriousUser'),
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment:
                                (AppLangVersionUtils.isYd() ||
                                    AppLangVersionUtils.isTk())
                                ? MainAxisAlignment.spaceAround
                                : MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const WalletPage(),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.wallet_outlined),
                              ),
                              UpgradePlanButton(
                                width: null,
                                height: 35,
                                borderRadius: 12,
                              ),
                              if (AppLangVersionUtils.isYd())
                                IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const CampaignPage(),
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.sports_esports_outlined),
                                ),
                            ],
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
                      controller: _tabController,
                      indicatorColor: Colors.white,
                      indicatorWeight: 2,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white54,
                      labelPadding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width < 375
                            ? 8
                            : 15,
                      ),
                      tabs: tabWidgets,
                    ),
                  ),
                ),
              ],
              body: Stack(
                children: [
                  TabBarView(
                    controller: _tabController,
                    physics: const ClampingScrollPhysics(),
                    children: tabViews,
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 60,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onHorizontalDragStart: (_) {
                        _dragAccumulatedX = 0.0;
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
    );
  }

  Widget _buildBioText(String bioText) {
    final i18n = ref.read(i18nNotifierProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        const textStyle = TextStyle(
          color: Color.fromARGB(179, 240, 240, 240),
          fontSize: 12,
        );
        const maxLines = 2;

        final textPainter = TextPainter(
          text: TextSpan(text: bioText, style: textStyle),
          maxLines: maxLines,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
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

  Widget _buildVipDurationChip(int validDays, String days) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.workspace_premium, color: Colors.amber, size: 13),
          const SizedBox(width: 5),
          Text(
            '$validDays $days',
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountItem(String label, int count, {VoidCallback? onTap}) {
    String formatCount(int n) {
      if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
      if (n >= 10000) return '${(n / 1000).toStringAsFixed(1)}K';
      return '$n';
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatCount(count),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  void _bindContentProviders(UserInfo user) {
    videoProvider = userVideoListProvider(user.id);
    postProvider = userPostListProvider(user.id);
  }

  void _applyUserData(UserInfo user) {
    _user = user;
    _coverUrl = user.cover;
    _isLoadingCover = false;
  }

  void _scheduleFollowStateSync(UserInfo user) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _container
          .read(userFollowProvider(user.id).notifier)
          .setFromBackend(
            isFollowed: user.isFollowed,
            fansCount: user.fansCount ?? 0,
            followCount: user.followCount ?? 0,
          );
    });
  }

  Future<void> _syncFollowStateNow(UserInfo user) async {
    _container
        .read(userFollowProvider(user.id).notifier)
        .setFromBackend(
          isFollowed: user.isFollowed,
          fansCount: user.fansCount ?? 0,
          followCount: user.followCount ?? 0,
        );
  }

  Future<void> _refreshUserData({bool refreshLists = false}) async {
    if (_isRefreshingUserData || !mounted) return;

    _isRefreshingUserData = true;
    try {
      final detail = await _container
          .read(currentUserProvider.notifier)
          .refreshUserInfo();
      if (!mounted) return;

      if (detail != null) {
        setState(() {
          _applyUserData(detail);
        });
        await _syncFollowStateNow(detail);
      } else {
        setState(() {
          _isLoadingCover = false;
        });
      }

      if (refreshLists) {
        _container.read(videoProvider.notifier).fetch(refresh: true);
        _container.read(postProvider.notifier).fetch(refresh: true);
      }
    } finally {
      _isRefreshingUserData = false;
    }
  }

  void _showCredentialsDialog() {
    if (!mounted) return;
    final currentUser = ref.read(currentUserProvider);
    final accountUser = currentUser?.id == _user.id ? currentUser! : _user;
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => AccountCredentialsDialog(user: accountUser),
    );
  }

  String _credentialsDialogSeenKey(String userId) {
    return 'credentials_dialog_seen_$userId';
  }

  Future<void> _maybeShowCredentialsDialogOnce() async {
    if (_hasAutoShownCredentialsDialog || _isCheckingCredentialsDialog) return;
    if (!mounted) return;

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null || currentUser.id != _user.id) return;

    _isCheckingCredentialsDialog = true;
    try {
      final seen =
          StorageService.instance.getValue<bool>(
            _credentialsDialogSeenKey(currentUser.id),
          ) ??
          false;
      if (seen) {
        _hasAutoShownCredentialsDialog = true;
        return;
      }

      _hasAutoShownCredentialsDialog = true;
      await StorageService.instance.setValue(
        _credentialsDialogSeenKey(currentUser.id),
        true,
      );
      if (!mounted) return;
      _showCredentialsDialog();
    } finally {
      _isCheckingCredentialsDialog = false;
    }
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
