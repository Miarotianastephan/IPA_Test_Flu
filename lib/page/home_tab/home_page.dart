import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/constants/ad_placement.dart';
import 'package:live_app/provider/api_provider.dart';
import 'package:live_app/provider/ad_provider.dart';
import 'package:live_app/provider/app_config_provider.dart';
import 'package:live_app/provider/cumulative_watch_time_provider.dart';
import 'package:live_app/provider/current_tab_provider.dart';
import 'package:live_app/provider/home_video_list_provider.dart';
// import 'package:live_app/widgets/home_tab/short_video_grid_page.dart';

import '../../utils/platform_check.dart';
import '../../widgets/home_tab/short_videos_page.dart';
import '../../widgets/lazy_indexed_stack.dart';
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
  // Old grid/extra-tab keys kept here for reference only.
  // final _videoPage3Key = GlobalKey<ShortVideosPageState>();
  // final _gridPageKey = GlobalKey<ShortVideoGridPageState>();

  late TabController tabController;
  int _activeHomeTabIndex = 1;
  bool _headerHidden = false;
  List<bool> hasUserInfos = [false, false, false, false];

  late final List<PageController> _videoControllers;
  final List<int> _currentVideoIndices = [0, 0, 0];

  @override
  void initState() {
    super.initState();
    _videoControllers = List.generate(2, (_) => PageController());
    tabController = TabController(length: 2, vsync: this, initialIndex: 1);
    tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    final nextIndex = tabController.index;
    if (_activeHomeTabIndex != nextIndex && mounted) {
      setState(() => _activeHomeTabIndex = nextIndex);
    }
    if (!tabController.indexIsChanging) {
      if (mounted) setState(() {});
    }
    if (tabController.index == 3) {
      ref.read(cumulativeWatchTimeProvider.notifier).stopTracking();
    }
    // Keep controllers stable per tab. Replacing/disposing them here breaks
    // ShortVideosPage's page listener binding and can cause later items to be
    // rendered as cover-only placeholders.
    // _disposeInactiveControllers();
  }

  // Legacy optimization kept for reference only.
  // It disposes inactive tab controllers, but that causes the active
  // ShortVideosPage to hold a stale listener on the previous controller.
  // void _disposeInactiveControllers() {
  //   for (int i = 0; i < _videoControllers.length; i++) {
  //     if (i != tabController.index && _videoControllers[i] != null) {
  //       _videoControllers[i]?.dispose();
  //       _videoControllers[i] = null;
  //     }
  //   }
  // }

  PageController _getOrCreateController(int index) {
    return _videoControllers[index];
  }

  void _markVideoAsSeen(int displayIndex, int type) {
    final int realVideoIndex = _getRealVideoIndex(displayIndex, type);

    final videoList = ref.read(homeVideoListProvider((type, 0))).list;
    if (videoList.isNotEmpty && realVideoIndex < videoList.length) {
      String videoId = videoList[realVideoIndex].id;
      final videoService = ref.read(videoServiceProvider);
      videoService.seen(videoId).then((_) {}).catchError((e) {
        debugPrint('Error marking video as seen: $e');
      });
    }
  }

  int _getRealVideoIndex(int displayIndex, int type) {
    final config = ref.read(appConfigProvider);
    final int adsAfter = config.data?.adsAfter ?? 10;
    final adCount =
        ref.read(adListProvider(AdPlacement.videoFeedInFeed)).list.length;
    if (adCount <= 0) return displayIndex;
    final adsBefore = (displayIndex + 1) ~/ (adsAfter + 1);
    return displayIndex - adsBefore;
  }

  bool _isAdPage(int displayIndex) {
    final config = ref.read(appConfigProvider);
    final int adsAfter = config.data?.adsAfter ?? 10;
    final adCount =
        ref.read(adListProvider(AdPlacement.videoFeedInFeed)).list.length;
    if (adCount <= 0) return false;
    return (displayIndex + 1) % (adsAfter + 1) == 0;
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
    }
    // Old grid/extra-tab refresh logic kept for reference only.
    // else if (index == 2) {
    //   await _videoPage3Key.currentState?.fetch(refresh: true);
    // } else if (index == 3) {
    //   await _gridPageKey.currentState?.refresh();
    // }

    setState(() {
      _isRefreshing = false;
      _refreshHeaderHeight = 0.0; // 收回
    });
  }

  @override
  void dispose() {
    for (final controller in _videoControllers) {
      controller.dispose();
    }
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Padding(
          padding: EdgeInsets.only(
            bottom: PlatformCheck.isWebIOS ? 73 : 53,
          ),
          child: Stack(
            children: [
              LazyIndexedStack(
                index: _activeHomeTabIndex,
                children: [
                  _buildVideoPage(_videoPage1Key, 1, 0),
                  _buildVideoPage(_videoPage2Key, 2, 1),
                ],
              ),
              Visibility(
                visible: !_headerHidden,
                child: SafeArea(
                  top: true,
                  bottom: false,
                  child: AnimatedOpacity(
                    opacity: 1.0 -
                        (_refreshHeaderHeight / _maxHeaderHeight).clamp(
                          0.0,
                          1.0,
                        ),
                    duration: const Duration(milliseconds: 100),
                    child: TikTokHeader(controller: tabController),
                  ),
                ),
              ),
              // Align(
              //   alignment: Alignment.centerRight,
              //   child: SizedBox(
              //     width: tabController.index == 3 ? 0 : 60,
              //     // 右侧80像素不触发 TabBarView
              //     child: GestureDetector(
              //       behavior: HitTestBehavior.translucent,
              //       onHorizontalDragUpdate: (details) {
              //         if (_headerHidden) return;
              //         if (hasUserInfos[tabController.index] == false) return;
              //         // 这里处理 TikTokScaffold 的左右滑动
              //         widget.tkcontroller?.animateToX(
              //           details.delta.dx,
              //         ); // 或者调用你的方法
              //       },
              //       onHorizontalDragEnd: (details) {
              //         if (_headerHidden) return;
              //         if (hasUserInfos[tabController.index] == false) return;
              //         widget.tkcontroller?.animateToRight();
              //       },
              //     ),
              //   ),
              // ),
            ],
          ),
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
    final controller = _getOrCreateController(tabIndex);
    final currentVideoIndex = _currentVideoIndices[tabIndex];

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
        isActive: tabIndex == tabController.index,
        type: type,
        controller: controller,
        currentIndex: currentVideoIndex,
        onPageChanged: (index) {
          final isAd = _isAdPage(index);
          ref.read(isOnAdPageProvider.notifier).state = isAd;
          if (!isAd) {
            _markVideoAsSeen(index, type);
          }
          if (mounted) {
            setState(() {
              _currentVideoIndices[tabIndex] = index;
            });
          }
        },
        onUserTap: (info) {
          widget.tkcontroller?.animateToRight();
        },
        onShowComment: () {
          setState(() {
            _headerHidden = true;
          });
          // widget.tkcontroller?.enableGesture = false;
        },
        onHideComment: () {
          setState(() {
            _headerHidden = false;
          });
          // widget.tkcontroller?.enableGesture = true;
        },
        hasData: (int index, bool has) {
          setState(() {
            hasUserInfos[index] = has;
          });
          if (has && _currentVideoIndices[index] == 0) {
            if (!_isAdPage(0)) {
              _markVideoAsSeen(0, index + 1);
            }
          }
        },
      ),
    );
  }

  // Legacy grid page implementation kept for reference only.
  // /// 精选页（瀑布流）
  // Widget _buildGridPage(
  //   GlobalKey<ShortVideoGridPageState> key,
  //   int type,
  //   int tabIndex,
  // ) {
  //   return NotificationListener<ScrollNotification>(
  //     onNotification: (scrollNotification) {
  //       if (_headerHidden) return false;
  //       if (scrollNotification is OverscrollNotification) {
  //         if (scrollNotification.metrics.axis != Axis.vertical) {
  //           return false;
  //         }
  //
  //         setState(() {
  //           _refreshHeaderHeight =
  //               (_refreshHeaderHeight - scrollNotification.overscroll).clamp(
  //                 0.0,
  //                 _maxHeaderHeight,
  //               );
  //         });
  //       }
  //
  //       if (scrollNotification is ScrollEndNotification) {
  //         if (_refreshHeaderHeight >= _maxHeaderHeight && !_isRefreshing) {
  //           _handleRefresh();
  //         } else {
  //           WidgetsBinding.instance.addPostFrameCallback((_) {
  //             setState(() {
  //               _refreshHeaderHeight = 0.0;
  //             });
  //           });
  //         }
  //       }
  //       return false;
  //     },
  //     child: ShortVideoGridPage(
  //       key: key,
  //       type: type,
  //       onUserTap: (info) {
  //         widget.tkcontroller?.animateToRight();
  //       },
  //     ),
  //   );
  // }
}
