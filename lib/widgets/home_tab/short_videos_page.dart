import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/i18n_provider.dart';

import '../../models/video_info.dart';
import '../../provider/home_video_list_provider.dart';
import '../empty_widget.dart';
import '../loading_widget.dart';
import '../video/short_video_item.dart';
import 'tiktok_page_scroll_physics.dart';

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
  int _lastReportedPage = 0;
  int? _lastOffset;
  final Set<int> _readyIndices = {};
  bool _isAttemptingNextBlocked = false;

  static const int _paginationThreshold = 5;

  @override
  void initState() {
    super.initState();
    _lastReportedPage = widget.currentIndex;
    // 初始化加载
    Future.microtask(() {
      fetch(refresh: true);
    });
    widget.controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!widget.controller.hasClients) return;

    final double pageDouble = widget.controller.page ?? 0;
    final int page = pageDouble.round();

    if (_isAttemptingNextBlocked) {
      final int currentPage = pageDouble.floor();
      final int nextIndex = currentPage + 1;

      final state = ref.read(homeVideoListProvider((widget.type, 0)));
      final currentOffset = state.offset;

      final bool isNextInRange = nextIndex < state.list.length;

      final bool isNextReady =
          !isNextInRange || _readyIndices.contains(nextIndex + currentOffset);

      if (isNextReady) {
        setState(() => _isAttemptingNextBlocked = false);
      } else if (pageDouble <= currentPage) {
        setState(() => _isAttemptingNextBlocked = false);
      }
    }

    if (page != _lastReportedPage) {
      _lastReportedPage = page;
      widget.onPageChanged?.call(page);

      final notifier = ref.read(
        homeVideoListProvider((widget.type, 0)).notifier,
      );
      final state = ref.read(homeVideoListProvider((widget.type, 0)));

      if (page >= state.list.length - _paginationThreshold) {
        if (state.finished) {
          notifier.recycleVideos();
        } else if (!state.loading) {
          notifier.fetch();
        }
      }
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

      if (refresh && mounted) {
        setState(() {
          _readyIndices.clear();
        });
      }

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
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);

    final state = ref.watch(homeVideoListProvider((widget.type, 0)));

    final int currentOffset = state.offset;
    if (_lastOffset != null && currentOffset > _lastOffset!) {
      final int diff = currentOffset - _lastOffset!;
      if (widget.controller.hasClients) {
        final double currentPage = widget.controller.page ?? 0;
        final double newPage = (currentPage - diff).clamp(0, double.infinity);

        final double viewport = widget.controller.position.viewportDimension;
        if (viewport > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (widget.controller.hasClients) {
              widget.controller.jumpTo(newPage * viewport);
            }
          });
        }
      }
    }
    _lastOffset = currentOffset;

    final notifier = ref.read(homeVideoListProvider((widget.type, 0)).notifier);
    Widget child;

    if (state.loading && state.list.isEmpty) {
      child = Container(color: Colors.black, child: const LoadingWidget());
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
        child: Scrollable(
          key: ValueKey('scrollable_${widget.type}'),
          controller: widget.controller,
          axisDirection: AxisDirection.down,
          physics: DirectionalScrollPhysics(
            readyIndices: _readyIndices,
            videosCount: videos.length,
            currentOffset: state.offset,
            onAttemptBlock: () {
              if (!_isAttemptingNextBlocked) {
                _isAttemptingNextBlocked = true;
              }
            },
            parent: _commentVisible
                ? const NeverScrollableScrollPhysics()
                : const TikTokPageScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
          ),
          viewportBuilder: (context, position) {
            return Viewport(
              offset: position,
              axisDirection: AxisDirection.down,

              cacheExtent: MediaQuery.of(context).size.height * 2,
              cacheExtentStyle: CacheExtentStyle.pixel,

              slivers: [
                SliverFillViewport(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final video = videos[index];
                    final virtualIndex = index + state.offset;

                    return ShortVideoItem(
                      key: ValueKey('video_${widget.type}_${video.id}'),

                      onReset: () {
                        if (_readyIndices.remove(virtualIndex)) {
                          setState(() {});
                        }
                      },

                      onBufferingChanged: (isBuffering) {
                        final changed = isBuffering
                            ? _readyIndices.remove(virtualIndex)
                            : _readyIndices.add(virtualIndex);

                        if (changed && mounted) {
                          setState(() {});
                        }
                      },

                      onInitialized: () {
                        if (!mounted) return;

                        final added = _readyIndices.add(virtualIndex);

                        final page = widget.controller.hasClients
                            ? widget.controller.page ?? 0
                            : widget.currentIndex.toDouble();

                        final currentVirtualPage = page.floor() + state.offset;

                        _readyIndices.removeWhere(
                          (i) => (i - currentVirtualPage).abs() > 12,
                        );

                        if (_isAttemptingNextBlocked &&
                            _readyIndices.contains(currentVirtualPage + 1)) {
                          _isAttemptingNextBlocked = false;
                        }

                        if (added) setState(() {});
                      },

                      onShowComment: () {
                        if (!_commentVisible) {
                          setState(() => _commentVisible = true);
                          widget.onShowComment();
                        }
                      },

                      onHideComment: () {
                        if (_commentVisible) {
                          setState(() => _commentVisible = false);
                          widget.onHideComment();
                        }
                      },

                      videoInfo: video,
                      onUserTap: widget.onUserTap,
                      onVideoInfoChange: (updatedVideo) {
                        if (video.isFollow != updatedVideo.isFollow) {
                          notifier.updateFollowStatus(
                            updatedVideo.user.id,
                            updatedVideo.isFollow,
                          );
                        }
                        notifier.updateVideo(updatedVideo);
                      },
                    );
                  }, childCount: videos.length),
                ),
              ],
            );
          },
        ),
      );
    }

    return Stack(
      children: [
        child,
        if (_isAttemptingNextBlocked)
          const Positioned(
            bottom: kToolbarHeight * 3,
            left: 0,
            right: 0,
            child: Center(
              child: BouncingDotsLoader(),
            ),
          ),
      ],
    );
  }
}

class DirectionalScrollPhysics extends ScrollPhysics {
  final Set<int> readyIndices;
  final int videosCount;
  final int currentOffset;
  final VoidCallback? onAttemptBlock;

  const DirectionalScrollPhysics({
    required this.readyIndices,
    required this.videosCount,
    required this.currentOffset,
    this.onAttemptBlock,
    super.parent,
  });

  @override
  DirectionalScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return DirectionalScrollPhysics(
      readyIndices: readyIndices,
      videosCount: videosCount,
      currentOffset: currentOffset,
      onAttemptBlock: onAttemptBlock,
      parent: buildParent(ancestor),
    );
  }

  bool _shouldBlockForward(ScrollMetrics position) {
    final double pixels = position.pixels;
    final double viewport = position.viewportDimension;
    if (viewport <= 0) return false;

    final int currentIndex = (pixels / viewport).floor();

    final int nextIndex = currentIndex + 1;

    final bool isNextReady =
        nextIndex >= videosCount ||
        readyIndices.contains(nextIndex + currentOffset);

    return !isNextReady;
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    if (offset < 0 && _shouldBlockForward(position)) {
      onAttemptBlock?.call();
      return 0.0; // block any forward movement
    }
    return super.applyPhysicsToUserOffset(position, offset);
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    if (value < position.pixels) return 0.0;

    final double pixels = position.pixels;
    final double viewport = position.viewportDimension;
    if (viewport <= 0) return 0.0;

    final double delta = value - pixels;
    if (delta <= 0) return 0.0;

    final int currentIndex = (pixels / viewport).floor();
    final double currentBoundary = currentIndex * viewport;

    final double maxSkipBoundary = (currentIndex + 4) * viewport;
    if (value >= maxSkipBoundary) {
      return value - (maxSkipBoundary - 0.001);
    }
    if (value > currentBoundary && _shouldBlockForward(position)) {
      onAttemptBlock?.call();
      return value - currentBoundary;
    }

    return super.applyBoundaryConditions(position, value);
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    if (velocity > 0 && _shouldBlockForward(position)) {
      onAttemptBlock?.call();
      return null;
    }
    return super.createBallisticSimulation(position, velocity);
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) => true;
}

class BouncingDotsLoader extends StatefulWidget {
  final Color color;
  final double dotSize;
  final int dotCount;

  const BouncingDotsLoader({
    super.key,
    this.color = Colors.white,
    this.dotSize = 6.0,
    this.dotCount = 3,
  });

  @override
  State<BouncingDotsLoader> createState() => _BouncingDotsLoaderState();
}

class _BouncingDotsLoaderState extends State<BouncingDotsLoader>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.dotCount,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0, end: -8).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    _startAnimation();
  }

  void _startAnimation() async {
    for (int i = 0; i < widget.dotCount; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      _controllers[i].repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.dotCount, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              child: Transform.translate(
                offset: Offset(0, _animations[index].value),
                child: Container(
                  width: widget.dotSize,
                  height: widget.dotSize,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
