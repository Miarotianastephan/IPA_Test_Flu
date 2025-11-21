import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:live_app/l10n/app_localizations.dart';

import '../../api/services/forum_service.dart';
import '../../models/forum_comment.dart';
import '../../models/page_params.dart';
import '../../provider/api_provider.dart';
import '../encrypted_image.dart';

/// 当前用户对这条评论的投票状态
enum _VoteState { none, up, down }

class ForumCommentItem extends ConsumerStatefulWidget {
  final ForumComment comment;
  final bool isChild;
  final bool darkStyle;
  final void Function(ForumComment comment)? onReply;

  const ForumCommentItem({
    super.key,
    required this.comment,
    this.onReply,
    this.isChild = false,
    this.darkStyle = false,
  });

  @override
  ConsumerState<ForumCommentItem> createState() => _ForumCommentItemState();
}

class _ForumCommentItemState extends ConsumerState<ForumCommentItem> {
  bool expanded = false;
  bool loading = false;
  bool childLoaded = false;

  List<ForumComment> childComments = [];
  late final ForumService forumService;

  late _VoteState voteState; // 当前用户对这条评论的投票状态
  late bool isLike; // 仍保留给 UI 使用（等同于 voteState == up）
  late int upvoteCount;
  late int downvoteCount;

  @override
  void initState() {
    super.initState();
    forumService = ref.read(forumServiceProvider);

    if (widget.comment.isLike) {
      voteState = _VoteState.up;
    } else if (widget.comment.isDownVote) {
      voteState = _VoteState.down;
    } else {
      voteState = _VoteState.none;
    }

    isLike = voteState == _VoteState.up;

    upvoteCount = widget.comment.upvoteCount;
    downvoteCount = widget.comment.downvoteCount;
  }

  /// 根据新状态更新本地计数（乐观更新）
  void _applyVoteTransition(_VoteState from, _VoteState to) {
    if (from == to) return;

    // 先减掉旧状态
    if (from == _VoteState.up) {
      upvoteCount = (upvoteCount - 1).clamp(0, 999999);
    } else if (from == _VoteState.down) {
      downvoteCount = (downvoteCount - 1).clamp(0, 999999);
    }

    // 再加上新状态
    if (to == _VoteState.up) {
      upvoteCount++;
    } else if (to == _VoteState.down) {
      downvoteCount++;
    }
  }

  /// 统一设置投票状态：none / up / down
  Future<void> _setVoteState(_VoteState newState) async {
    final oldState = voteState;
    final oldUp = upvoteCount;
    final oldDown = downvoteCount;

    setState(() {
      _applyVoteTransition(oldState, newState);
      voteState = newState;
      isLike = (voteState == _VoteState.up);
    });

    try {
      if (newState == _VoteState.none) {
        // 取消所有投票（无论是赞还是踩）
        await forumService.commentVoteCancel(widget.comment.id);
      } else {
        final type = newState == _VoteState.up ? "up" : "down";
        await forumService.commentVote(widget.comment.id, type);
      }
    } catch (e) {
      // 请求失败，回滚
      setState(() {
        voteState = oldState;
        upvoteCount = oldUp;
        downvoteCount = oldDown;
        isLike = (voteState == _VoteState.up);
      });
    }
  }

  /// 点赞按钮点击
  Future<void> toggleLike() async {
    // 当前是 up => 取消；否则 => 切换为 up
    final target = (voteState == _VoteState.up)
        ? _VoteState.none
        : _VoteState.up;
    await _setVoteState(target);
  }

  /// 踩按钮点击
  Future<void> toggleDownvote() async {
    // 当前是 down => 取消；否则 => 切换为 down
    final target = (voteState == _VoteState.down)
        ? _VoteState.none
        : _VoteState.down;
    await _setVoteState(target);
  }

  Future<void> loadChildComments() async {
    if (loading || childLoaded) return;

    setState(() => loading = true);

    try {
      final resp = await forumService.commentChildren(
        PageParams(page: 1, limit: 50),
        widget.comment.id,
      );

      final list = (resp.data?.list ?? [])
          .map((e) => ForumComment.fromJson(e.toJson()))
          .toList();

      setState(() {
        childComments = list;
        childLoaded = true;
      });
    } catch (e) {
      debugPrint("加载子评论失败: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.comment;

    final localizations = AppLocalizations.of(context)!;

    final textColor = widget.darkStyle ? Colors.black : Colors.white;
    final subTextColor = widget.darkStyle ? Colors.grey : Colors.grey[300];
    final replyColor = widget.darkStyle ? Colors.blue : Colors.lightBlueAccent;

    final user = c.commentUser;
    final toUser = c.commentToUser;

    final isDownSelected = voteState == _VoteState.down;

    return InkWell(
      onTap: () => widget.onReply?.call(widget.comment),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: widget.darkStyle ? Colors.black12 : Colors.white24,
                  width: 0.4,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserAvatar(
                  userId: user?.id,
                  url: user?.avatar,
                  nickname: user?.nickname,
                  size: 32,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            user?.nickname ?? localizations.unknownUser,
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          if (toUser != null && widget.isChild) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right,
                              size: 16,
                              color: subTextColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              toUser.nickname,
                              style: TextStyle(
                                color: replyColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 4),

                      Text(
                        c.content,
                        style: TextStyle(color: textColor, fontSize: 15),
                      ),

                      const SizedBox(height: 6),

                      Row(
                        children: [
                          Text(
                            DateFormat('yyyy-MM-dd  HH:mm').format(c.createdAt),
                            style: TextStyle(color: subTextColor, fontSize: 12),
                          ),
                          const Spacer(),

                          InkWell(
                            onTap: toggleLike,
                            borderRadius: BorderRadius.circular(20),
                            child: Row(
                              children: [
                                Icon(
                                  isLike
                                      ? Icons.thumb_up
                                      : Icons.thumb_up_outlined,
                                  size: 18,
                                  color: isLike
                                      ? Colors.lightBlueAccent
                                      : subTextColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "$upvoteCount",
                                  style: TextStyle(
                                    color: subTextColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 14),

                          InkWell(
                            onTap: toggleDownvote,
                            borderRadius: BorderRadius.circular(20),
                            child: Row(
                              children: [
                                Icon(
                                  isDownSelected
                                      ? Icons.thumb_down
                                      : Icons.thumb_down_outlined,
                                  size: 18,
                                  color: isDownSelected
                                      ? Colors.orangeAccent
                                      : subTextColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "$downvoteCount",
                                  style: TextStyle(
                                    color: subTextColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      if (c.childCount > 0)
                        TextButton(
                          onPressed: () async {
                            setState(() => expanded = !expanded);
                            if (expanded) await loadChildComments();
                          },
                          child: Text(
                            "${expanded ? localizations.collapse : localizations.expand} "
                            "${c.childCount} ${localizations.replies}",
                            style: TextStyle(color: replyColor, fontSize: 13),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (expanded)
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Column(
                children: [
                  ...childComments.map(
                    (item) => ForumCommentItem(
                      comment: item,
                      isChild: true,
                      darkStyle: widget.darkStyle,
                      onReply: widget.onReply,
                    ),
                  ),
                  if (loading)
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
