import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/l10n/app_localizations.dart';
import 'package:live_app/models/video_comment.dart';
import 'package:live_app/widgets/comment_item_replies.dart';

import '../../api/services/video_service.dart';
import '../../models/page_params.dart';
import '../../provider/api_provider.dart';
import '../comment_item.dart';
import 'comment_input_bar.dart';

class CommentsModal extends ConsumerStatefulWidget {
  final VoidCallback onTapClose;
  final VoidCallback onComment;
  final AnimationController transitionController;
  final double height;
  final int videoId;
  final Function(VideoComment)? onCommentTap;

  const CommentsModal({
    super.key,
    required this.onTapClose,
    required this.onComment,
    required this.transitionController,
    required this.height,
    required this.videoId,
    this.onCommentTap,
  });

  @override
  ConsumerState<CommentsModal> createState() => CommentsModalState();
}

class CommentsModalState extends ConsumerState<CommentsModal> {
  final Set<int> _expandedComments = {};
  List<VideoComment> comments = [];
  late final VideoService videoService;
  final TextEditingController _commentController = TextEditingController();

  int page = 1;
  bool _loaded = false; // 是否加载过
  bool _loading = false; // 是否正在加载
  bool _finished = false; // 是否加载完成所有评论

  double? dragStartX;

  VideoComment? _replyingTo;
  String? _replyingToName;

  @override
  void initState() {
    super.initState();
    videoService = ref.read(videoServiceProvider);
    _loadData();
  }

  Future<void> _loadData() async {
    if (_loaded || _loading) return;
    await fetchComments(refresh: true);
  }

  Future<void> fetchComments({bool refresh = false}) async {
    try {
      if (refresh) {
        setState(() {
          _loading = true;
          _finished = false;
        });
      }

      final nextPage = refresh ? 1 : page + 1;
      final apiResponse = await videoService.videoRootCommentList(
        PageParams(page: nextPage),
        widget.videoId,
      );
      if (!mounted) return;

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
        page = nextPage;
        if (refresh) {
          comments = newList;
          _loading = false;
        } else {
          comments.addAll(newList);
        }
        _loaded = true;
        if (apiResponse.data?.total != null &&
            comments.length >= apiResponse.data!.total) {
          _finished = true;
        }
      });
    } catch (e, st) {
      debugPrint("${refresh ? '刷新' : '加载更多'}评论失败: $e");
      debugPrintStack(stackTrace: st);
      if (refresh && mounted) {
        setState(() {
          _loading = false;
          _loaded = true;
        });
      }
    }
  }

  void onReplyComment(VideoComment comment) {
    if (widget.onCommentTap != null) {
      widget.onCommentTap!(comment);
    } else {
      setState(() {
        _replyingTo = comment;
        _replyingToName = comment.commentUser?.nickname;
      });
      FocusScope.of(context).requestFocus(FocusNode());
    }
  }

  @override
  Widget build(BuildContext context) {
    final topLevelComments = comments;
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragUpdate: (details) {
              widget.transitionController.value -=
                  details.primaryDelta! / widget.height;
            },
            onVerticalDragEnd: (details) {
              if (details.velocity.pixelsPerSecond.dy > 700) {
                widget.transitionController.fling(velocity: -1);
                widget.onTapClose();
              } else if (widget.transitionController.value < 0.5) {
                widget.transitionController.fling(velocity: -1);
                widget.onTapClose();
              } else {
                widget.transitionController.fling(velocity: 1);
              }
            },
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.comments,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      InkWell(
                        onTap: widget.onTapClose,
                        child: const Icon(Icons.close, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              backgroundColor: Colors.white,
              onRefresh: () => fetchComments(refresh: true),
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification.metrics.pixels >=
                          notification.metrics.maxScrollExtent - 100 &&
                      !_loading &&
                      !_finished) {
                    fetchComments();
                  }
                  return false;
                },
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 0, top: 10),
                  itemCount: topLevelComments.length + 1,
                  itemBuilder: (context, index) {
                    if (index == topLevelComments.length) {
                      if (_finished) {
                        return Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context)!.noMoreComments,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      } else if (_loading) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    }
                    final comment = topLevelComments[index];
                    final expanded = _expandedComments.contains(comment.id);
                    return CommentItem(
                      key: ValueKey(comment.id),
                      comment: comment,
                      isChild: false,
                      expanded: expanded,
                      onClick: onReplyComment,
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
                              padding: const EdgeInsets.only(
                                left: 56.0,
                                bottom: 8.0,
                              ),
                              child: ChildCommentsList(
                                parentId: comment.id,
                                onClick: onReplyComment,
                              ),
                            )
                          : null,
                      darkStyle: true,
                      childCount: comment.childCount,
                    );
                  },
                ),
              ),
            ),
          ),
          AnimatedPadding(
            duration: const Duration(milliseconds: 0),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                color: Colors.white,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 0),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: CommentInputBar(
                    controller: _commentController,
                    replyingToName: _replyingToName,
                    onCancelReply: () {
                      setState(() {
                        _replyingTo = null;
                        _replyingToName = null;
                      });
                    },
                    darkStyle: true,
                    onSend: (content) async {
                      await videoService.commentVideo(
                        widget.videoId,
                        content,
                        parentId: _replyingTo?.id,
                      );
                      setState(() {
                        _replyingTo = null;
                        _replyingToName = null;
                      });
                      fetchComments(refresh: true);
                      widget.onComment();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChildCommentsList extends ConsumerStatefulWidget {
  final int parentId;
  final void Function(VideoComment) onClick;
  final bool darkStyle;

  const ChildCommentsList({
    super.key,
    required this.parentId,
    required this.onClick,
    this.darkStyle = true,
  });

  @override
  ConsumerState<ChildCommentsList> createState() => _ChildCommentsListState();
}

class _ChildCommentsListState extends ConsumerState<ChildCommentsList> {
  List<VideoComment> _childComments = [];
  int _page = 1;
  bool _loading = false;
  bool _finished = false;

  late final VideoService videoService;

  @override
  void initState() {
    super.initState();
    videoService = ref.read(videoServiceProvider);
    _fetchData(refresh: true);
  }

  Future<void> _fetchData({bool refresh = false}) async {
    if (_loading || _finished && !refresh) return;

    setState(() => _loading = true);
    try {
      final nextPage = refresh ? 1 : _page + 1;
      final apiResponse = await videoService.videoChildCommentList(
        PageParams(page: nextPage),
        widget.parentId,
      );

      final newList = (apiResponse.data?.list ?? [])
          .map((e) => VideoComment.fromJson(e.toJson()))
          .toList();

      setState(() {
        if (refresh) {
          _childComments = newList;
          _page = 1;
          _finished = newList.isEmpty;
        } else {
          _childComments.addAll(newList);
          _page = nextPage;
          if (newList.isEmpty) _finished = true;
        }
        if (apiResponse.data?.total == _childComments.length) {
          _finished = true;
        }
      });
    } catch (e, st) {
      debugPrint("加载子评论失败: $e");
      debugPrintStack(stackTrace: st);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ..._childComments.map(
          (c) => Padding(
            key: ValueKey(c.id),
            padding: const EdgeInsets.only(bottom: 8.0),
            child: CommentItemReplies(comment: c, darkStyle: widget.darkStyle),
          ),
        ),
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        if (!_finished && !_loading)
          TextButton(
            onPressed: () => _fetchData(),
            child: Text(
              AppLocalizations.of(context)!.loadMoreReplies,
              style: TextStyle(
                color: widget.darkStyle ? Colors.blue : Colors.lightBlueAccent,
              ),
            ),
          ),
      ],
    );
  }
}
