import 'package:flutter/material.dart';

import '../../models/video_info.dart';
import '../Animation/follow_splash_animation.dart';
import '../encrypted_image.dart';

class VideoOverlayActions extends StatefulWidget {
  final VideoInfo video;
  final bool isFollowed;
  final bool isLike;
  final bool isFavorite;
  final int commentCount;
  final Future<void> Function() showModal;
  final Future<void> Function(bool) onFollowChanged;
  final Future<void> Function(bool) onLikeChanged;
  final Future<void> Function(bool) onFavoriteChanged; // 新增收藏回调
  final void Function(VideoInfo) onUserTap;
  final void Function(bool) onHidden;

  const VideoOverlayActions({
    super.key,
    required this.video,
    required this.isFollowed,
    required this.isLike,
    required this.isFavorite,
    required this.commentCount,
    required this.showModal,
    required this.onFollowChanged,
    required this.onLikeChanged,
    required this.onFavoriteChanged,
    required this.onUserTap,
    required this.onHidden,
  });

  @override
  State<VideoOverlayActions> createState() => _VideoOverlayActionsState();
}

class _VideoOverlayActionsState extends State<VideoOverlayActions>
    with SingleTickerProviderStateMixin {
  bool _showActions = true;

  late AnimationController _likeController;
  late Animation<double> _scaleAnimation, _opacityAnimation;
  final GlobalKey _followBtnKey = GlobalKey();
  OverlayEntry? _splashEntry;
  int _favoriteCount = 0;
  int _likeCount = 0;

  @override
  void initState() {
    super.initState();
    _favoriteCount = widget.video.favoriteCount;
    _likeCount = widget.video.likeCount;
    _likeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween(begin: 0.5, end: 1.5).animate(
      CurvedAnimation(parent: _likeController, curve: Curves.easeOutBack),
    );

    //透明度先升，再降
    _opacityAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50, // 前 50% 的时间淡入
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50, // 后 50% 的时间淡出
      ),
    ]).animate(_likeController);
  }

  @override
  void dispose() {
    _splashEntry?.remove();
    _splashEntry = null;
    _likeController.dispose();
    super.dispose();
  }

  Widget _buildAction({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required int count,
    required bool showText,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Icon(icon, color: color, size: 36),
        ),
        if (showText)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              count.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
      ],
    );
  }

  // 点赞特效
  void _showLikeSplash(Offset position) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: position.dx - 40,
          top: position.dy - 40,
          child: AnimatedBuilder(
            animation: _likeController,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                ),
              );
            },
            child: const Icon(Icons.favorite, size: 80, color: Colors.red),
          ),
        );
      },
    );

    overlay.insert(entry);

    _likeController.forward(from: 0).whenComplete(() {
      entry.remove();
    });
  }

  void _showFollowSplash() {
    final overlay = Overlay.of(context);
    final renderBox =
        _followBtnKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _splashEntry = OverlayEntry(
      builder: (ctx) => Stack(
        children: [
          Positioned(
            left: offset.dx + size.width / 2 - 20, // 居中放置，假设动画大小约40
            top: offset.dy + size.height / 2 - 20,
            child: IgnorePointer(
              child: FollowSplashAnimation(
                onFinish: () {
                  _splashEntry?.remove();
                  _splashEntry = null;
                },
              ),
            ),
          ),
        ],
      ),
    );
    overlay.insert(_splashEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 底部文字
        if (_showActions)
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 15, bottom: 20, right: 80),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.video.user.nickname != null
                        ? "@${widget.video.user.nickname}"
                        : "",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.video.description,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

        // 右侧操作栏
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 15, bottom: 20),
            child: SizedBox(
              width: 56,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_showActions) ...[
                      SizedBox(
                        width: 56,
                        height: 64,
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.topCenter,
                          children: [
                            UserAvatar(
                              url:
                                  widget.video.user.avatar ??
                                  "https://i.pravatar.cc/350",
                              nickname: widget.video.user.nickname,
                              size: 48,
                              onTap: () => widget.onUserTap.call(widget.video),
                            ),
                            if (!widget.isFollowed)
                              Positioned(
                                bottom: 5,
                                child: GestureDetector(
                                  key: _followBtnKey,
                                  onTap: () {
                                    _showFollowSplash();
                                    widget.onFollowChanged(true);
                                  },
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),

                      Builder(
                        builder: (btnContext) => _buildAction(
                          icon: Icons.favorite,
                          color: widget.isLike ? Colors.red : Colors.white,
                          onTap: () async {
                            var value = !widget.isLike;
                            if (value) {
                              final renderBox =
                                  btnContext.findRenderObject() as RenderBox;
                              final position = renderBox.localToGlobal(
                                renderBox.size.center(Offset.zero),
                              );
                              _showLikeSplash(position);
                            }
                            await widget.onLikeChanged(value);
                            if (value) {
                              setState(() {
                                _likeCount++;
                              });
                            } else {
                              setState(() {
                                _likeCount--;
                              });
                            }
                          },
                          showText: true,
                          count: _likeCount,
                        ),
                      ),
                      const SizedBox(height: 15),

                      _buildAction(
                        icon: Icons.comment,
                        color: Colors.white,
                        onTap: () => widget.showModal(),
                        showText: true,
                        count: widget.commentCount,
                      ),
                      const SizedBox(height: 15),

                      _buildAction(
                        icon: widget.isFavorite
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: widget.isFavorite ? Colors.yellow : Colors.white,
                        onTap: () async {
                          var value = !widget.isFavorite;
                          await widget.onFavoriteChanged(value);
                          if (value) {
                            setState(() {
                              _favoriteCount++;
                            });
                          } else {
                            setState(() {
                              _favoriteCount--;
                            });
                          }
                        },
                        showText: true,
                        count: _favoriteCount,
                      ),
                      const SizedBox(height: 15),

                      _buildAction(
                        icon: Icons.share,
                        color: Colors.white,
                        showText: false,
                        onTap: () {
                          debugPrint("分享视频: ${widget.video.title}");
                        },
                        count: 0,
                      ),
                      const SizedBox(height: 40),
                    ],

                    GestureDetector(
                      onTap: () {
                        widget.onHidden(!_showActions);
                        setState(() {
                          _showActions = !_showActions;
                        });
                      },
                      child: Icon(
                        _showActions ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
