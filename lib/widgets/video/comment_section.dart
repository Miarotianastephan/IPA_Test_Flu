import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/widgets/empty_widget.dart';

import '../../models/video_comment.dart';
import '../../provider/video_comments_provider.dart';
import '../comment/comment_input_bar.dart';
import '../comment_item.dart';
import '../comment_item_replies.dart';

class CommentSection extends ConsumerStatefulWidget {
  final int videoId;
  final VoidCallback? onComment;

  const CommentSection({super.key, required this.videoId, this.onComment});

  @override
  ConsumerState<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends ConsumerState<CommentSection> {
  final Set<int> _expandedComments = {};
  final TextEditingController _commentController = TextEditingController();
  final Set<int> _highlightedComments = {};

  void _onReply(VideoComment comment) async {
    // Ici tu peux ouvrir CommentDetailPage ou juste gérer le reply inline
    // Pour simplifier, on fait juste un scroll vers le commentaire
    // ou un callback
  }

  Widget _buildCommentItem(VideoComment comment) {
    final expanded = _expandedComments.contains(comment.id);
    final isHighlighted = _highlightedComments.contains(comment.id);
    final state = ref.watch(commentsProvider(widget.videoId));
    final repliesState = state.repliesMap[comment.id] ?? RepliesState();

    Widget item = CommentItem(
      key: ValueKey(comment.id),
      comment: comment,
      isChild: false,
      darkStyle: false,
      expanded: expanded,
      onClick: _onReply,
      onToggleExpand: () {
        setState(() {
          if (expanded) {
            _expandedComments.remove(comment.id);
          } else {
            _expandedComments.add(comment.id);
            // Charger les replies si nécessaire
            ref
                .read(commentsProvider(widget.videoId).notifier)
                .fetchReplies(comment.id);
          }
        });
      },
      childComments: expanded
          ? Padding(
              padding: const EdgeInsets.only(left: 56.0, bottom: 8.0),
              child: Column(
                children: [
                  ...repliesState.list.map(
                    (c) => Padding(
                      key: ValueKey(c.id),
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: CommentItemReplies(comment: c, darkStyle: false),
                    ),
                  ),
                  if (repliesState.loading)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  if (!repliesState.finished && !repliesState.loading)
                    TextButton(
                      onPressed: () => ref
                          .read(commentsProvider(widget.videoId).notifier)
                          .fetchReplies(comment.id),
                      child: Text(
                        ref
                            .read(i18nNotifierProvider.notifier)
                            .translate("loadMoreReplies"),
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                ],
              ),
            )
          : null,
      childCount: comment.childCount,
    );

    if (isHighlighted) {
      item = TweenAnimationBuilder<Color?>(
        tween: ColorTween(
          begin: Colors.yellow.withOpacity(0.5),
          end: Colors.transparent,
        ),
        duration: const Duration(seconds: 1),
        onEnd: () => setState(() => _highlightedComments.remove(comment.id)),
        builder: (context, color, child) =>
            Container(color: color, child: child),
        child: item,
      );
    }

    return item;
  }

  @override
  void initState() {
    super.initState();
    // Charger les commentaires initiaux
    Future.microtask(
      () => ref
          .read(commentsProvider(widget.videoId).notifier)
          .fetch(refresh: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(commentsProvider(widget.videoId));
    final comments = state.comments;
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref
                .read(commentsProvider(widget.videoId).notifier)
                .fetch(refresh: true),
            child: state.loading && !state.loadedOnce
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
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
                    padding: const EdgeInsets.only(bottom: 60, top: 10),
                    itemCount: comments.length + 1,
                    itemBuilder: (context, index) {
                      if (index < comments.length) {
                        return _buildCommentItem(comments[index]);
                      }
                      if (state.finished) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              translate("noMoreComments"),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      }
                      if (state.loading) {
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
        SafeArea(
          top: false,
          child: CommentInputBar(
            controller: _commentController,
            darkStyle: false,
            onSend: (content) async {
              if (content.trim().isEmpty) return;

              try {
                await ref
                    .read(commentsProvider(widget.videoId).notifier)
                    .videoService
                    .commentVideo(widget.videoId, content);

                _commentController.clear();
                await ref
                    .read(commentsProvider(widget.videoId).notifier)
                    .fetch(refresh: true);
                widget.onComment?.call();
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
