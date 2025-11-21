import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/forum_comment.dart';
import '../../provider/forum_comments_provider.dart';
import 'forum_comment_item.dart';

class ForumCommentsList extends ConsumerWidget {
  final int postId;
  final void Function(ForumComment comment)? onReply;

  const ForumCommentsList({
    super.key,
    required this.postId,
    this.onReply,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(forumCommentsProvider(postId));
    final comments = state.comments;

    /// 首次加载
    if (!state.firstLoaded && state.loading) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    /// 空数据
    if (state.firstLoaded && comments.isEmpty && !state.loading) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: Text("暂无评论", style: TextStyle(color: Colors.white70)),
        ),
      );
    }

    /// 纯列表渲染（由外层滚动）
    return Column(
      children: [
        ...comments.map((comment) {
          return ForumCommentItem(
            comment: comment,
            onReply: onReply,
          );
        }),

        /// 加载中
        if (state.loading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
          ),

        /// 结束提示
        if (state.finished)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                "已经到底啦",
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ),
      ],
    );
  }
}