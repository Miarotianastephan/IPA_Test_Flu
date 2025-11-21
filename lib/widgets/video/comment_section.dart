import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/l10n/app_localizations.dart';

import '../../api/services/video_service.dart';
import '../../models/page_params.dart';
import '../../models/video_comment.dart';
import '../../page/comment_detail_page.dart';
import '../../provider/api_provider.dart';
import '../comment/comment_input_bar.dart';
import '../comment/comments_modal.dart';
import '../comment_item.dart';

class CommentSection extends ConsumerStatefulWidget {
  final int videoId;
  final VoidCallback? onComment; // 新增回调

  const CommentSection({super.key, required this.videoId, this.onComment});

  @override
  ConsumerState<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends ConsumerState<CommentSection> {
  final Set<int> _expandedComments = {};
  final TextEditingController _commentController = TextEditingController();
  late final VideoService videoService;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final Set<int> _highlightedComments = {};

  List<VideoComment> comments = [];
  int page = 1;
  bool _loading = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      videoService = ref.read(videoServiceProvider);
      _fetchComments(refresh: true);
    });
  }

  Future<void> _fetchComments({bool refresh = false}) async {
    if (_loading) return;
    setState(() => _loading = true);

    final nextPage = refresh ? 1 : page;
    try {
      final apiResponse = await videoService.videoRootCommentList(
        PageParams(page: nextPage),
        widget.videoId,
      );

      final newList = (apiResponse.data?.list ?? [])
          .map((e) => VideoComment.fromJson(e.toJson()))
          .where((comment) => comment.parentId == 0)
          .toList();

      for (var comment in newList) {
        try {
          final childResponse = await videoService.videoChildCommentList(
            PageParams(page: 1),
            comment.id,
          );
          if (!mounted) return;

          final index = newList.indexOf(comment);
          if (index != -1) {
            newList[index] = VideoComment(
              id: comment.id,
              videoId: comment.videoId,
              userId: comment.userId,
              content: comment.content,
              parentId: comment.parentId,
              likeCount: comment.likeCount,
              createdAt: comment.createdAt,
              childCount: childResponse.data?.total ?? comment.childCount,
              isLike: comment.isLike,
              commentUser: comment.commentUser,
              commentToUser: comment.commentToUser,
              vCommentLikes: comment.vCommentLikes,
            );
          }
        } catch (e) {
          debugPrint(
            'Error fetching child count for comment ${comment.id}: $e',
          );
        }
      }

      setState(() {
        if (refresh) {
          comments = newList;
          page = 2;
        } else {
          comments.addAll(newList);
          page += 1;
        }

        _finished =
            apiResponse.data?.total != null &&
            comments.length >= apiResponse.data!.total;
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  void _onReply(VideoComment comment) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CommentDetailPage(parentComment: comment, videoId: widget.videoId),
      ),
    );

    _fetchComments(refresh: true);
  }

  Widget _buildCommentItem(
    VideoComment comment,
    int index,
    Animation<double> animation,
  ) {
    final expanded = _expandedComments.contains(comment.id);
    final isHighlighted = _highlightedComments.contains(comment.id);

    Widget item = CommentItem(
      key: ValueKey(comment.id),
      darkStyle: false,
      isChild: false,
      comment: comment,
      onClick: _onReply,
      expanded: expanded,
      onToggleExpand: () {
        setState(() {
          if (expanded) {
            _expandedComments.remove(comment.id);
          } else {
            _expandedComments.add(comment.id);
          }
        });
      },
      childComments: expanded
          ? Padding(
              padding: const EdgeInsets.only(left: 56.0, bottom: 8.0),
              child: ChildCommentsList(
                darkStyle: false,
                parentId: comment.id,
                onClick: _onReply,
              ),
            )
          : null,
      childCount: comment.childCount,
    );

    if (isHighlighted) {
      // 高亮动画
      item = TweenAnimationBuilder<Color?>(
        tween: ColorTween(
          begin: Colors.yellow.withValues(alpha: 0.5),
          end: Colors.transparent,
        ),
        duration: const Duration(seconds: 1),
        onEnd: () {
          setState(() {
            _highlightedComments.remove(comment.id);
          });
        },
        builder: (context, color, child) {
          return Container(color: color, child: child);
        },
        child: item,
      );
    }

    return SizeTransition(sizeFactor: animation, child: item);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            color: Colors.white,
            backgroundColor: Colors.black,
            onRefresh: () => _fetchComments(refresh: true),
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.pixels >=
                        notification.metrics.maxScrollExtent - 100 &&
                    !_loading &&
                    !_finished) {
                  _fetchComments();
                }
                return false;
              },

              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 60, top: 10),

                itemCount: comments.length + 1,

                itemBuilder: (context, index) {
                  if (index < comments.length) {
                    return _buildCommentItem(
                      comments[index],
                      index,
                      kAlwaysCompleteAnimation,
                    );
                  }
                  if (_finished) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)!.noMoreComments,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }
                  if (_loading) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: CommentInputBar(
            controller: _commentController,
            darkStyle: false,
            onSend: (content) async {
              if (content.trim().isEmpty) return;

              try {
                final newCommentJson = await videoService.commentVideo(
                  widget.videoId,
                  content,
                );

                final newComment = newCommentJson.data!;

                setState(() {
                  comments.insert(0, newComment);
                  _highlightedComments.add(newComment.id);
                  _listKey.currentState?.insertItem(0);
                });

                _commentController.clear();

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                });
                widget.onComment?.call();
                _fetchComments(refresh: true);
              } catch (e) {
                debugPrint('Error sending comment: $e');
              }
            },
          ),
        ),
      ],
    );
  }
}
