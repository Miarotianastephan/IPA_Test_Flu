import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/config/storage_config.dart';
import 'package:live_app/l10n/app_localizations.dart';
import 'package:live_app/models/userinfo.dart';
import 'package:live_app/page/login/login_with_username.dart';
import '../../models/video_info.dart';
import '../../provider/home_video_list_provider.dart';
import '../empty_widget.dart';
import '../loading_widget.dart';
import '../video/short_video_item.dart';

class ShortVideosPage extends ConsumerStatefulWidget {
  final PageController controller;
  final int currentIndex;
  final int tabIndex;
  final ValueChanged<int>? onPageChanged;
  final int type;
  final Function(VideoInfo videoInfo) onUserTap; // 新增：点击头像回调
  final VoidCallback onShowComment; //当显示评论的时候
  final VoidCallback onHideComment; //当隐藏评论的时候
  final Function(int, bool) hasData; //当没有数据的时候

  const ShortVideosPage({
    super.key,
    required this.controller,
    required this.currentIndex,
    required this.type,
    required this.onUserTap,
    required this.onShowComment,
    required this.onHideComment,
    required this.hasData,
    this.onPageChanged,
    required this.tabIndex,
  });

  @override
  ConsumerState<ShortVideosPage> createState() => ShortVideosPageState();
}

class ShortVideosPageState extends ConsumerState<ShortVideosPage>
    with AutomaticKeepAliveClientMixin {
  bool _commentVisible = false;
  UserInfo? _userInfo;

  @override
  void initState() {
    super.initState();
    // 初始化加载
    Future.microtask(() {
      getUserFromCache();
      fetch(refresh: true);
    });
  }

  Future<void> getUserFromCache() async {
    final data = await StorageService.instance.getValue("user_info");
    if (data != null && data.isNotEmpty) {
      final map = data is String ? jsonDecode(data) : data;
      setState(() {
        _userInfo = UserInfo.fromJson(map);
      });
    }
  }

  Future<void> fetch({bool refresh = false}) async {
    try {
      final notifier = ref.read(
        homeVideoListProvider((widget.type, 0)).notifier,
      );
      final state = ref.read(homeVideoListProvider((widget.type, 0)));

      // 如果正在加载或已加载完毕且不是刷新，就不重复加载
      if (state.loading || (state.finished && !refresh)) return;

      // 调用 Provider 的 fetchVideos 方法
      await notifier.fetch(refresh: refresh);

      final newState = ref.read(homeVideoListProvider((widget.type, 0)));

      // 更新外层状态
      if (refresh && newState.list.isEmpty) {
        widget.hasData(widget.tabIndex, false);
      } else {
        widget.hasData(widget.tabIndex, true);
      }
    } catch (e, st) {
      debugPrint("${refresh ? '刷新' : '加载更多'}视频失败: $e");
      debugPrintStack(stackTrace: st);
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final state = ref.watch(homeVideoListProvider((widget.type, 0)));
    final notifier = ref.read(homeVideoListProvider((widget.type, 0)).notifier);
    Widget child;

    if (state.loading && state.list.isEmpty) {
      child = LoadingWidget(
        message: "${AppLocalizations.of(context)!.loadingInProgress}...",
      );
    } else if (!state.loading &&
        (_userInfo?.isVisitor ?? true) &&
        widget.tabIndex == 0) {
      child = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
            ),
            const SizedBox(height: 24),
            Text(
              "Sign in to follow videos",
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Create an account or log in to save and access your favorite videos anytime",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginWithUsernamePage(),
                  ),
                );
              },
              child: const Text(
                "Log In",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    } else if (!state.loading && state.list.isEmpty) {
      child = CustomScrollView(
        controller: widget.controller,
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).size.height + 1,
              child: const EmptyWidget(),
            ),
          ),
        ],
      );
    } else {
      final videos = state.list;

      child = SafeArea(
        top: false,
        child: PageView.builder(
          controller: widget.controller,
          onPageChanged: (index) {
            if (widget.onPageChanged != null) {
              widget.onPageChanged!(index);
            }
            // 倒数第二页触发加载更多
            if (index >= videos.length - 2 &&
                !state.loading &&
                !state.finished) {
              notifier.fetch();
            }
          },
          scrollDirection: Axis.vertical,
          physics: _commentVisible
              ? NeverScrollableScrollPhysics()
              : widget.currentIndex == 0
              ? const ClampingScrollPhysics()
              : const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
          itemCount: videos.length,
          itemBuilder: (context, index) {
            return ShortVideoItem(
              onShowComment: () {
                setState(() => _commentVisible = true);
                widget.onShowComment();
              },
              onHideComment: () {
                setState(() => _commentVisible = false);
                widget.onHideComment();
              },
              videoInfo: videos[index],
              onUserTap: widget.onUserTap,
              onVideoInfoChange: (video) {
                if (videos[index].isFollow != video.isFollow) {
                  notifier.updateFollowStatus(video.user.id, video.isFollow);
                }
                notifier.updateVideo(video);
              },
            );
          },
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      // 动画时长
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      transitionBuilder: (Widget child, Animation<double> animation) {
        // 淡入淡出 + 缩放
        return FadeTransition(opacity: animation, child: child);
      },
      child: child,
    );
  }
}
