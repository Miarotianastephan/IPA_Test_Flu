import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/video_info.dart';
import '../api/services/video_service.dart';
import '../provider/api_provider.dart';
import '../provider/cumulative_watch_time_provider.dart';
import '../provider/web_video_mute_provider.dart';
import '../widgets/comment/comment_input_bar.dart';
import '../widgets/video/short_video_item.dart';
import 'search_page.dart';
import 'user_detail_page.dart';

class ShortVideoDetailPage extends ConsumerStatefulWidget {
  final int initialIndex;
  final ValueChanged<int>? onPageChanged;
  final dynamic provider;
  final List<VideoInfo> Function(dynamic state)? selectVideos;
  final String? heroTagPrefix;
  final bool isUserDetailPop;

  const ShortVideoDetailPage({
    super.key,
    required this.initialIndex,
    this.onPageChanged,
    required this.provider,
    this.selectVideos,
    this.heroTagPrefix,
    this.isUserDetailPop = false,
  });

  @override
  ConsumerState<ShortVideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends ConsumerState<ShortVideoDetailPage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late PageController _pageController;
  int _currentIndex = 0;

  double _dragOffsetX = 0.0;
  double _dragOffsetY = 0.0;
  double _horizontalDrag = 0.0;
  late AnimationController _controller;
  late Animation<double> _animation;
  late final VideoService videoService;
  final TextEditingController _commentController = TextEditingController();
  final Map<int, ShortVideoItemController> _controllers = {};

  bool isHideHeader = false;

  bool _userDetailFullyOpen = false; // 记录用户页是否曾经完全展开

  ShortVideoItemController _getController(int index) {
    return _controllers.putIfAbsent(index, () => ShortVideoItemController());
  }

  @override
  void initState() {
    super.initState();
    videoService = ref.read(videoServiceProvider);
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffsetX += details.delta.dx;
      _dragOffsetY += details.delta.dy;
      if (_dragOffsetX < 0) _dragOffsetX = 0;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dragOffsetX > 150) {
      Navigator.pop(context);
    } else {
      _controller.forward(from: 0).then((_) {
        setState(() {
          _dragOffsetX = 0;
          _dragOffsetY = 0;
          _controller.reset();
        });
      });
    }
  }

  /// 新增：处理左滑用户详情页逻辑
  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (!widget.isUserDetailPop) return;

    // 只处理左滑（右→左）
    if (details.delta.dx >= 0) return;
    setState(() {
      _horizontalDrag += details.delta.dx;
    });
  }

  Future<void> _animateHorizontalTo(
    double target, {
    int durationMs = 200,
  }) async {
    final animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durationMs),
    );
    final anim = Tween<double>(
      begin: _horizontalDrag,
      end: target,
    ).animate(CurvedAnimation(parent: animController, curve: Curves.easeOut));
    anim.addListener(() {
      setState(() {
        _horizontalDrag = anim.value;
        _userDetailFullyOpen = false;
      });
    });
    await animController.forward();
    animController.dispose();
  }

  void _onHorizontalDragEnd(DragEndDetails details) async {
    if (!widget.isUserDetailPop) return;
    final width = MediaQuery.of(context).size.width;
    if (_horizontalDrag < -width * 0.25) {
      await _animateHorizontalTo(-width);
      _userDetailFullyOpen = true;
    } else {
      await _animateHorizontalTo(0);
      _userDetailFullyOpen = false;
    }
  }

  // 用户页完全展开后，右滑关闭时跟随手指自然滑动
  void _onHorizontalReverseUpdate(DragUpdateDetails details) {
    setState(() {
      _horizontalDrag += details.delta.dx; // 跟随手指自然滑动
      if (_horizontalDrag > 0) _horizontalDrag = 0; // 防止越界
    });
  }

  // 用户页右滑结束，自动补齐回位动画
  void _onHorizontalReverseEnd(DragEndDetails details) async {
    final width = MediaQuery.of(context).size.width;
    if (_horizontalDrag < -width * 0.5) {
      await _animateHorizontalTo(-width);
      _userDetailFullyOpen = true;
    } else {
      await _animateHorizontalTo(0);
      _userDetailFullyOpen = false;
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    _commentController.dispose();
    _pageController.dispose();
    _controller.dispose();
    ref.read(cumulativeWatchTimeProvider.notifier).stopTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final provider = widget.provider;
    final notifier = ref.read(provider.notifier);
    final providerState = ref.watch(provider);
    final videos = widget.selectVideos != null
        ? widget.selectVideos!(providerState)
        : providerState.list;

    if (videos.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (_currentIndex >= videos.length) {
      _currentIndex = videos.length - 1;
    }

    final dragDistance = _dragOffsetX.abs();
    final scale = 1.0 - (dragDistance / 600).clamp(0.0, 0.4);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanUpdate: (details) {
        if (isHideHeader) return;
        final width = MediaQuery.of(context).size.width;
        final isLeftSwipe = details.delta.dx < 0;
        final isRightSwipe = details.delta.dx > 0;

        if (isRightSwipe) {
          // 如果用户页未拉出 -> 正常返回视频详情页
          if (_horizontalDrag == 0) {
            _onDragUpdate(details);
          }
          // 如果用户页已拉出 -> 恢复用户页位置
          else if (_horizontalDrag < 0 && widget.isUserDetailPop) {
            _onHorizontalReverseUpdate(details);
          }
          return;
        }

        if (isLeftSwipe) {
          // 如果之前右滑导致页面缩小，先平滑恢复大小再处理用户页逻辑
          if (_dragOffsetX > 0 || _dragOffsetY > 0) {
            final anim = AnimationController(
              vsync: this,
              duration: const Duration(milliseconds: 150),
            );
            final tween = Tween<double>(
              begin: _dragOffsetX,
              end: 0,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut));
            tween.addListener(() {
              setState(() {
                _dragOffsetX = tween.value;
                _dragOffsetY = 0;
              });
            });
            anim.forward().then((_) => anim.dispose());
          }
          // 当用户页未拉出时 -> 拉出用户详情页
          if (widget.isUserDetailPop && _horizontalDrag > -width) {
            _onHorizontalDragUpdate(details);
          }
        }
      },

      // 手势结束
      onPanEnd: (details) async {
        if (isHideHeader) return;
        final width = MediaQuery.of(context).size.width;

        if (widget.isUserDetailPop && _horizontalDrag <= -width * 0.8) {
          _onHorizontalReverseEnd(details);
          return;
        }

        if (_horizontalDrag < 0 && _horizontalDrag > -width * 0.8) {
          // 如果之前已经完全展开过，则优先恢复到已展开位置（避免回弹到 0）
          if (_userDetailFullyOpen) {
            await _animateHorizontalTo(0);
            return;
          }
          // 否则按阈值判断展开或回弹
          _onHorizontalDragEnd(details);
          return;
        }

        if (_horizontalDrag == 0 || _horizontalDrag > 0) {
          _onDragEnd(details);
        }
      },
      child: Stack(
        children: [
          // 背景层：UserDetailPage，随着左滑渐显
          if (widget.isUserDetailPop)
            Positioned.fill(
              child: Offstage(
                offstage: _horizontalDrag > 0, // 或者更宽松一点
                child: Transform.translate(
                  offset: Offset(
                    MediaQuery.of(context).size.width + _horizontalDrag,
                    0,
                  ),
                  child: UserDetailPage(
                    onBackSlide: (x) {
                      setState(() {
                        final width = MediaQuery.of(context).size.width;
                        _horizontalDrag += x;
                        _horizontalDrag = _horizontalDrag.clamp(-width, 0);
                      });
                    },
                    key: ValueKey(videos[_currentIndex].id),
                    user: videos[_currentIndex].user,
                    onBack: () {
                      _animateHorizontalTo(0);
                    },
                  ),
                ),
              ),
            ),

          // 主体视频页
          Transform.translate(
            offset: Offset(_horizontalDrag, 0),
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    _dragOffsetX * (1 - _animation.value),
                    _dragOffsetY * (1 - _animation.value),
                  ),
                  child: Transform.scale(
                    scale: scale + (1 - scale) * _animation.value,
                    child: child,
                  ),
                );
              },
              child: _buildMainContent(context, videos, notifier),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    dynamic videos,
    dynamic notifier,
  ) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    scrollDirection: Axis.vertical,
                    physics: isHideHeader
                        ? NeverScrollableScrollPhysics()
                        : BouncingScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                      widget.onPageChanged?.call(index);
                    },
                    itemCount: videos.length,
                    itemBuilder: (context, index) {
                      final heroTag = widget.heroTagPrefix != null
                          ? "${widget.heroTagPrefix}_${videos[index].id}"
                          : "video_${videos[index].id}";
                      var view = ShortVideoItem(
                        pageKey: "ShortVideoDetailPage",
                        isFirstItem: index == 0,
                        videoInfo: videos[index],
                        controller: _getController(index),
                        onUserTap: (videoInfo) async {
                          if (!widget.isUserDetailPop) {
                            Navigator.pop(context);
                            return;
                          }

                          final width = MediaQuery.of(context).size.width;
                          final animController = AnimationController(
                            vsync: this,
                            duration: const Duration(milliseconds: 200),
                          );

                          final anim =
                              Tween<double>(
                                begin: _horizontalDrag,
                                end: -width,
                              ).animate(
                                CurvedAnimation(
                                  parent: animController,
                                  curve: Curves.easeOut,
                                ),
                              );

                          anim.addListener(() {
                            setState(() {
                              _horizontalDrag = anim.value;
                            });
                          });

                          await animController.forward();
                          _userDetailFullyOpen = true;
                          animController.dispose();
                        },
                        onVideoInfoChange: (video) {
                          if (videos[index].isFollow != video.isFollow) {
                            notifier.updateFollowStatus(
                              video.user.id,
                              video.isFollow,
                            );
                          }
                          notifier.updateVideo(video);
                        },
                        onShowComment: () => setState(() {
                          isHideHeader = true;
                        }),
                        onHideComment: () => setState(() {
                          isHideHeader = false;
                        }),
                      );
                      return Center(
                        child: index == _currentIndex
                            ? Hero(tag: heroTag, child: view)
                            : view,
                      );
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom,
                  ),
                  color: Theme.of(context).colorScheme.primary,
                  child: CommentInputBar(
                    controller: _commentController,
                    darkStyle: false,
                    onSend: (content) async {
                      await videoService.commentVideo(
                        videos[_currentIndex].id,
                        content,
                      );
                      notifier.incrementCommentCount(videos[_currentIndex].id);
                      _getController(_currentIndex).updateCommentCount(
                        videos[_currentIndex].commentCount + 1,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (!isHideHeader)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),

          if (!isHideHeader)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 8,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (kIsWeb)
                    Consumer(
                      builder: (context, ref, child) {
                        final muteState = ref.watch(webVideoMuteProvider);
                        if (!muteState.isMuted) return const SizedBox.shrink();
                        return GestureDetector(
                          onTap: () {
                            ref
                                .read(webVideoMuteProvider.notifier)
                                .setMuted(false);
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Icon(
                              Icons.volume_off_rounded,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SearchPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
