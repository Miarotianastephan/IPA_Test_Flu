import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/l10n/app_localizations.dart';
import 'package:live_app/widgets/home_tab/short_video_grid_page.dart';
import '../../widgets/home_tab/short_videos_page.dart';
import '../../widgets/tiktok_header.dart';
import '../../widgets/tiktok_scaffold.dart';

class HomeTabPage extends ConsumerStatefulWidget {
  final TikTokScaffoldController? tkcontroller;

  const HomeTabPage({super.key, this.tkcontroller});

  @override
  ConsumerState<HomeTabPage> createState() => HomeTabPageState();
}

class HomeTabPageState extends ConsumerState<HomeTabPage>
    with SingleTickerProviderStateMixin {
  double screenWidth = 0;

  // 下拉刷新相关
  double _refreshHeaderHeight = 0.0;
  final double _maxHeaderHeight = 80.0;
  bool _isRefreshing = false;

  final _videoPage1Key = GlobalKey<ShortVideosPageState>();
  final _videoPage2Key = GlobalKey<ShortVideosPageState>();
  final _videoPage3Key = GlobalKey<ShortVideosPageState>();
  final _gridPageKey = GlobalKey<ShortVideoGridPageState>();

  late TabController tabController;
  bool _headerHidden = false;
  List<bool> hasUserInfos = [false, false, false, false];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this, initialIndex: 1);
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
      _refreshHeaderHeight = _maxHeaderHeight; // 展开
    });

    final index = tabController.index;
    if (index == 0) {
      await _videoPage1Key.currentState?.fetch(refresh: true);
    } else if (index == 1) {
      await _videoPage2Key.currentState?.fetch(refresh: true);
    } else if (index == 2) {
      await _videoPage3Key.currentState?.fetch(refresh: true);
    } else if (index == 3) {
      await _gridPageKey.currentState?.refresh();
    }

    setState(() {
      _isRefreshing = false;
      _refreshHeaderHeight = 0.0; // 收回
    });
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            TabBarView(
              controller: tabController,
              physics: _headerHidden
                  ? const NeverScrollableScrollPhysics() // 禁止滑动
                  : const ClampingScrollPhysics(), // 正常
              children: [
                _buildVideoPage(_videoPage1Key, 1, 0),
                _buildVideoPage(_videoPage2Key, 2, 1),
                _buildVideoPage(_videoPage3Key, 3, 2),
                _buildGridPage(_gridPageKey, 4, 3),
              ],
            ),
            Visibility(
              visible: !_headerHidden,
              child: SafeArea(
                top: true,
                bottom: false,
                child: AnimatedOpacity(
                  opacity:
                      1.0 -
                      (_refreshHeaderHeight / _maxHeaderHeight).clamp(0.0, 1.0),
                  duration: const Duration(milliseconds: 100),
                  child: TikTokHeader(controller: tabController),
                ),
              ),
            ),
            // 刷新提示文字
            Positioned(
              top: 00,
              left: 0,
              right: 0,
              child: SafeArea(
                top: true,
                bottom: false,
                child: Opacity(
                  opacity: (_refreshHeaderHeight / _maxHeaderHeight).clamp(
                    0.0,
                    1.0,
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, anim) =>
                          FadeTransition(opacity: anim, child: child),
                      child: _isRefreshing
                          ? Row(
                              key: const ValueKey("refreshing"),
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  AppLocalizations.of(context)!.refreshing,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              key: const ValueKey("pull"),
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.arrow_downward,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  AppLocalizations.of(context)!.pullToRefresh,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: tabController.index == 3 ? 0 : 60,
                // 右侧80像素不触发 TabBarView
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragUpdate: (details) {
                    if (_headerHidden) return;
                    if (hasUserInfos[tabController.index] == false) return;
                    // 这里处理 TikTokScaffold 的左右滑动
                    widget.tkcontroller?.animateToX(
                      details.delta.dx,
                    ); // 或者调用你的方法
                  },
                  onHorizontalDragEnd: (details) {
                    if (_headerHidden) return;
                    if (hasUserInfos[tabController.index] == false) return;
                    widget.tkcontroller?.animateToRight();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 视频流页面（上下滑）
  Widget _buildVideoPage(
    GlobalKey<ShortVideosPageState> key,
    int type,
    int tabIndex,
  ) {
    final controller = PageController();
    int currentVideoIndex = 0;

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (_headerHidden) return false;
        if (scrollNotification is OverscrollNotification &&
            controller.hasClients &&
            currentVideoIndex == 0) {
          setState(() {
            _refreshHeaderHeight =
                (_refreshHeaderHeight - scrollNotification.overscroll).clamp(
                  0.0,
                  _maxHeaderHeight,
                );
          });
        }

        if (scrollNotification is ScrollEndNotification) {
          if (_refreshHeaderHeight >= _maxHeaderHeight && !_isRefreshing) {
            _handleRefresh();
          } else {
            setState(() {
              _refreshHeaderHeight = 0.0;
            });
          }
        }
        return false;
      },
      child: ShortVideosPage(
        key: key,
        tabIndex: tabIndex,
        type: type,
        controller: controller,
        currentIndex: currentVideoIndex,
        onPageChanged: (index) {
          setState(() {
            currentVideoIndex = index;
          });
        },
        onUserTap: (info) {
          widget.tkcontroller?.animateToRight();
        },
        onShowComment: () {
          setState(() {
            _headerHidden = true;
          });
          widget.tkcontroller?.enableGesture = false;
        },
        onHideComment: () {
          setState(() {
            _headerHidden = false;
          });
          widget.tkcontroller?.enableGesture = true;
        },
        hasData: (int index, bool has) {
          setState(() {
            hasUserInfos[index] = has;
          });
        },
      ),
    );
  }

  /// 精选页（瀑布流）
  Widget _buildGridPage(
    GlobalKey<ShortVideoGridPageState> key,
    int type,
    int tabIndex,
  ) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (_headerHidden) return false;
        if (scrollNotification is OverscrollNotification) {
          if (scrollNotification.metrics.axis != Axis.vertical) {
            return false;
          }

          setState(() {
            _refreshHeaderHeight =
                (_refreshHeaderHeight - scrollNotification.overscroll).clamp(
                  0.0,
                  _maxHeaderHeight,
                );
          });
        }

        if (scrollNotification is ScrollEndNotification) {
          if (_refreshHeaderHeight >= _maxHeaderHeight && !_isRefreshing) {
            _handleRefresh();
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _refreshHeaderHeight = 0.0;
              });
            });
          }
        }
        return false;
      },
      child: ShortVideoGridPage(
        key: key,
        type: type,
        onUserTap: (info) {
          widget.tkcontroller?.animateToRight();
        },
      ),
    );
  }
}
