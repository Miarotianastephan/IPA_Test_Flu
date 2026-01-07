import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/video_comment.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/widgets/comment_item_replies.dart';
import 'package:live_app/widgets/empty_widget.dart';

import '../../provider/video_comments_provider.dart';
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
  ConsumerState<CommentsModal> createState() => _CommentsModalState();
}

class _CommentsModalState extends ConsumerState<CommentsModal> {
  final Set<int> _expandedComments = {};
  final TextEditingController _commentController = TextEditingController();
  VideoComment? _replyingTo;
  String? _replyingToName;

  @override
  void initState() {
    super.initState();

    Future.microtask(
      () => ref
          .read(commentsProvider(widget.videoId).notifier)
          .fetch(refresh: true),
    );
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
    final state = ref.watch(commentsProvider(widget.videoId));
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);
    final comments = state.comments;

    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        children: [
          // Drag handle & header
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragUpdate: (details) {
              widget.transitionController.value -=
                  details.primaryDelta! / widget.height;
            },
            onVerticalDragEnd: (details) {
              if (details.velocity.pixelsPerSecond.dy > 700 ||
                  widget.transitionController.value < 0.5) {
                widget.transitionController.fling(velocity: -1);
                widget.onTapClose();
              } else {
                widget.transitionController.fling(velocity: 1);
              }
            },
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
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
                        translate("comments"),
                        style: const TextStyle(
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
          // Comments list
          Expanded(
            child: RefreshIndicator(
              backgroundColor: Colors.white,
              onRefresh: () async {
                await ref
                    .read(commentsProvider(widget.videoId).notifier)
                    .fetch(refresh: true);
              },
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification.metrics.pixels >=
                          notification.metrics.maxScrollExtent - 100 &&
                      !state.loading &&
                      !state.finished) {
                    ref.read(commentsProvider(widget.videoId).notifier).fetch();
                  }
                  return false;
                },
                child: state.loading && !state.loadedOnce
                    ? const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : comments.isEmpty
                    ? Center(
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: EmptyWidget(
                            icon: Icons.message_outlined,
                            message: translate("noCommentsYet"),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 0, top: 10),
                        itemCount: comments.length + 1,
                        itemBuilder: (context, index) {
                          if (index == comments.length) {
                            if (state.finished) {
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Center(
                                  child: Text(
                                    translate("noMoreComments"),
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ),
                              );
                            } else if (state.loading) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          }
                          final comment = comments[index];
                          final expanded = _expandedComments.contains(
                            comment.id,
                          );
                          final repliesState =
                              state.repliesMap[comment.id] ?? RepliesState();

                          return CommentItem(
                            key: ValueKey(comment.id),
                            comment: comment,
                            isChild: false,
                            expanded: expanded,
                            onClick: onReplyComment,
                            onToggleExpand: () {
                              if (expanded) {
                                setState(() {
                                  _expandedComments.remove(comment.id);
                                });
                              } else {
                                setState(() {
                                  _expandedComments.add(comment.id);
                                });
                                // Charger les replies au moment de l'expansion
                                ref
                                    .read(
                                      commentsProvider(widget.videoId).notifier,
                                    )
                                    .fetchReplies(comment.id);
                              }
                            },
                            childComments: expanded
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                      left: 56.0,
                                      bottom: 8.0,
                                    ),
                                    child: Column(
                                      children: [
                                        ...repliesState.list.map(
                                          (c) => Padding(
                                            key: ValueKey(c.id),
                                            padding: const EdgeInsets.only(
                                              bottom: 8.0,
                                            ),
                                            child: CommentItemReplies(
                                              comment: c,
                                              darkStyle: true,
                                              onClick: onReplyComment,
                                            ),
                                          ),
                                        ),
                                        if (repliesState.loading)
                                          const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        if (!repliesState.finished &&
                                            !repliesState.loading &&
                                            repliesState.list.isNotEmpty)
                                          TextButton(
                                            onPressed: () {
                                              ref
                                                  .read(
                                                    commentsProvider(
                                                      widget.videoId,
                                                    ).notifier,
                                                  )
                                                  .fetchReplies(comment.id);
                                            },
                                            child: Text(
                                              translate("loadMoreReplies"),
                                              style: const TextStyle(
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ),
                                      ],
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
          // Comment input
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
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
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
                      final parentId = _replyingTo?.id;

                      final response = await ref
                          .read(commentsProvider(widget.videoId).notifier)
                          .videoService
                          .commentVideo(
                            widget.videoId,
                            content,
                            parentId: parentId,
                          );

                      setState(() {
                        _replyingTo = null;
                        _replyingToName = null;
                      });

                      if (response.data != null) {
                        await ref
                            .read(commentsProvider(widget.videoId).notifier)
                            .addComment(response.data!);
                      }

                      await ref
                          .read(commentsProvider(widget.videoId).notifier)
                          .refreshAfterComment(parentId: parentId);

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
