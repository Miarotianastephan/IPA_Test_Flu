import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/database/download_database.dart';
import 'package:live_app/provider/download_video_provider.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/provider/user_follow_provider.dart';
import 'package:live_app/utils/utils.dart';
import 'package:live_app/widgets/download_button.dart';

import '../../models/video_info.dart';
import '../Animation/follow_splash_animation.dart';
import '../encrypted_image.dart';

class VideoOverlayActions extends ConsumerStatefulWidget {
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
  final VoidCallback? onCommentAdded;

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
    this.onCommentAdded,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _VideoOverlayActionsState();
}

class _VideoOverlayActionsState extends ConsumerState<VideoOverlayActions>
    with SingleTickerProviderStateMixin {
  bool _showActions = true;

  late AnimationController _likeController;
  late Animation<double> _scaleAnimation;
  final GlobalKey _followBtnKey = GlobalKey();
  OverlayEntry? _splashEntry;
  int _favoriteCount = 0;
  int _likeCount = 0;
  int _commentCount = 0;
  bool isTapLike = false;
  @override
  void initState() {
    super.initState();
    _favoriteCount = widget.video.favoriteCount;
    _likeCount = widget.video.likeCount;
    _commentCount = widget.commentCount;
    _likeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.2,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _likeController, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(VideoOverlayActions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.commentCount != widget.commentCount) {
      setState(() {
        _commentCount = widget.commentCount;
      });
    }
  }

  void incrementCommentCount() {
    setState(() {
      _commentCount++;
    });
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

  void _showLikeSplash(Offset position) {
    _splashEntry?.remove();
    setState(() {
      isTapLike = true;
    });
    _splashEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx - 40,
        top: position.dy - 40,
        child: AnimatedBuilder(
          animation: _likeController,
          builder: (context, child) {
            return Transform.scale(scale: _scaleAnimation.value, child: child);
          },
          child: const Icon(Icons.favorite, size: 80, color: Colors.red),
        ),
      ),
    );

    Overlay.of(context).insert(_splashEntry!);

    _likeController.forward(from: 0).whenComplete(() {
      _splashEntry?.remove();
      _splashEntry = null;
      setState(() {
        isTapLike = false;
      });
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
                  ExpandableText(widget.video.description),
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
                              url: widget.video.user.avatar,
                              nickname: widget.video.user.nickname,
                              size: 48,
                              onTap: () {
                                toUserDetailPage(
                                  context: context,
                                  ref: ref,
                                  userId: widget.video.userId,
                                  url: widget.video.user.avatar,
                                  nickname: widget.video.user.nickname,
                                );
                              },
                            ),
                            if (!widget.isFollowed)
                              Positioned(
                                bottom: 5,
                                child: GestureDetector(
                                  key: _followBtnKey,
                                  onTap: () async {
                                    _showFollowSplash();
                                    await ref
                                        .read(
                                          userFollowProvider(
                                            widget.video.userId.toString(),
                                          ).notifier,
                                        )
                                        .toggleFollow();
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
                          color: widget.isLike
                              ? Colors.red
                              : isTapLike == true
                              ? Colors.transparent
                              : Colors.white,
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
                        onTap: () {
                          widget.showModal();
                        },
                        showText: true,
                        count: _commentCount,
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

                      // Future feature
                      // _buildAction(
                      //   icon: Icons.share,
                      //   color: Colors.white,
                      //   showText: false,
                      //   onTap: () {},
                      //   count: 0,
                      // ),
                      // const SizedBox(height: 40),
                      StreamBuilder<Download?>(
                        stream: ref
                            .watch(offlineRepoProvider)
                            .db
                            .watchById(widget.video.id),
                        builder: (context, snapshot) {
                          final existing = snapshot.data;
                          final localPath = existing?.localPath;
                          final fileExists = localPath != null
                              ? File(localPath).existsSync()
                              : false;

                          if (existing == null) {
                            return DownloadButton(
                              videoInfo: widget.video,
                              filename: "video_${widget.video.id}.mp4",
                            );
                          }

                          switch (existing.status) {
                            case "completed":
                              if (fileExists) {
                                debugPrint(
                                  "Vidéo déjà téléchargée: $localPath ✅",
                                );
                                return const Icon(
                                  Icons.download_done,
                                  color: Colors.white,
                                  size: 28.0,
                                );
                              } else {
                                return DownloadButton(
                                  videoInfo: widget.video,
                                  filename: "video_${widget.video.id}.mp4",
                                );
                              }

                            case "paused":
                              debugPrint("Téléchargement en pause");
                              return IconButton(
                                icon: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                ),
                                onPressed: () async {
                                  final repo = ref.read(offlineRepoProvider);
                                  final i18nNotifier = ref.read(
                                    i18nNotifierProvider.notifier,
                                  );
                                  await repo.resumeDownload(
                                    id: widget.video.id,
                                    translate: i18nNotifier.translate,
                                  );
                                },
                              );

                            case "failed":
                              debugPrint("Téléchargement échoué");
                              return IconButton(
                                icon: const Icon(
                                  Icons.refresh,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  final repo = ref.read(offlineRepoProvider);
                                  final i18nNotifier = ref.read(
                                    i18nNotifierProvider.notifier,
                                  );
                                  await repo.downloadResource(
                                    id: widget.video.id,
                                    filename: "video_${widget.video.id}.mp4",
                                    translate: i18nNotifier.translate,
                                  );
                                },
                              );

                            case "cancelled":
                              debugPrint("Téléchargement annulé");
                              return DownloadButton(
                                videoInfo: widget.video,
                                filename: "video_${widget.video.id}.mp4",
                              );

                            default:
                              debugPrint("Vidéo non téléchargée: $localPath");
                              return DownloadButton(
                                videoInfo: widget.video,
                                filename: "video_${widget.video.id}.mp4",
                              );
                          }
                        },
                      ),
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

class ExpandableText extends StatefulWidget {
  final String text;
  const ExpandableText(this.text, {super.key});

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText>
    with SingleTickerProviderStateMixin {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => expanded = !expanded),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),

        curve: Curves.fastLinearToSlowEaseIn,
        child: Text(
          widget.text,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          maxLines: expanded ? null : 2,
          overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
