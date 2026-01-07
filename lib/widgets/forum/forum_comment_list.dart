import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/widgets/empty_widget.dart';

import '../../models/forum_comment.dart';
import '../../provider/forum_comments_provider.dart';
import 'forum_comment_item.dart';

class ForumCommentsList extends ConsumerWidget {
  final int postId;
  final void Function(ForumComment comment)? onReply;

  const ForumCommentsList({super.key, required this.postId, this.onReply});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(forumCommentsProvider(postId));
    final comments = state.comments;
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);

    /// 首次加载
    if (!state.firstLoaded && state.loading) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    /// 空数据
    if (state.firstLoaded && comments.isEmpty && !state.loading) {
      return Padding(
        padding: EdgeInsets.all(40),
        child: EmptyWidget(
          message: translate("noCommentsYet"),
          icon: Icons.message_outlined,
          color: Colors.white70,
        ),
      );
    }

    /// 纯列表渲染（由外层滚动）
    return Column(
      children: [
        ...comments.where((c) => c.parentId == null || c.parentId == 0).map((
          comment,
        ) {
          return ForumCommentItem(
            key: UniqueKey(),
            comment: comment,
            onReply: onReply,
            isChild: false,
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
          Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                translate("reachedEnd"),
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ),
      ],
    );
  }
}
