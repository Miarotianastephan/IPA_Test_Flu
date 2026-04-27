import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:live_app/config/storage_config.dart';
import 'package:live_app/models/userinfo.dart';
import 'package:live_app/provider/i18n_provider.dart';

import 'package:live_app/widgets/vip_badge.dart';

import '../models/video_comment.dart';
import '../provider/api_provider.dart';
import 'encrypted_image.dart';

class CommentItem extends ConsumerStatefulWidget {
  final VideoComment comment;
  final bool expanded;
  final VoidCallback onToggleExpand;
  final Widget? childComments;
  final bool isChild;
  final void Function(VideoComment) onClick;
  final bool darkStyle;
  final int childCount;

  const CommentItem({
    super.key,
    required this.comment,
    required this.expanded,
    required this.onToggleExpand,
    required this.isChild,
    required this.onClick,
    this.childComments,
    this.darkStyle = true,
    this.childCount = 0,
  });

  @override
  ConsumerState<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends ConsumerState<CommentItem> {
  bool isLike = false;
  bool _isSubmittingLike = false;
  late int likeCount;

  @override
  void initState() {
    super.initState();
    likeCount = widget.comment.likeCount;
    _initializeLikeStatus();
  }

  Future<void> _initializeLikeStatus() async {
    try {
      final jsonString = await StorageService.instance.getValue("user_info");
      if (jsonString == null || jsonString.isEmpty) {
        setState(() {
          isLike = false;
        });
        return;
      }

      final currentUser = UserInfo.fromJson(jsonDecode(jsonString));

      bool userHasLiked = false;

      if (!widget.comment.isLike) {
        userHasLiked = false;
      } else if (widget.comment.vCommentLikes != null &&
          widget.comment.vCommentLikes!.isNotEmpty) {
        userHasLiked = widget.comment.vCommentLikes!.any(
          (like) => like.userId == currentUser.id,
        );
      }

      setState(() {
        isLike = userHasLiked;
      });
    } catch (e) {
      debugPrint("_initializeLikeStatus error: $e");
      setState(() {
        isLike = false;
      });
    }
  }

  Future<void> toggleLike() async {
    if (_isSubmittingLike) return;

    final previousIsLike = isLike;
    final previousLikeCount = likeCount;

    try {
      setState(() {
        _isSubmittingLike = true;
        if (isLike) {
          likeCount = (likeCount - 1).clamp(0, 999999);
        } else {
          likeCount++;
        }
        isLike = !isLike;
      });

      if (previousIsLike) {
        await ref
            .read(videoServiceProvider)
            .cancelCommentLike(widget.comment.id);
      } else {
        await ref.read(videoServiceProvider).likeComment(widget.comment.id);
      }
    } catch (e) {
      debugPrint("toggleLike error: $e");
      if (!mounted) return;
      setState(() {
        isLike = previousIsLike;
        likeCount = previousLikeCount;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingLike = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);
    final user = widget.comment.commentUser;
    final toUser = widget.comment.commentToUser;

    final textColor = widget.darkStyle ? Colors.black : Colors.white;
    final subTextColor = widget.darkStyle ? Colors.grey : Colors.grey[300];
    final replyColor = widget.darkStyle ? Colors.blue : Colors.lightBlueAccent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              widget.onClick(widget.comment);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserAvatar(
                    userId: user?.id,
                    url: user?.avatar,
                    nickname: user?.nickname,
                    vip: user?.vip,
                    size: 32,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 用户昵称 + 回复对象
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                user?.nickname ?? translate("unknownUser"),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            VipBadge(vip: user?.vip),
                            if (toUser != null && widget.isChild) ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.chevron_right,
                                size: 16,
                                color: subTextColor,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  toUser.nickname ?? "",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: replyColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              VipBadge(vip: toUser.vip, size: 14),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        // 评论内容
                        Text(
                          widget.comment.content,
                          style: TextStyle(color: textColor),
                        ),
                        const SizedBox(height: 4),
                        // 时间 + 点赞
                        Row(
                          children: [
                            Text(
                              DateFormat(
                                'yyyy-MM-dd  HH:mm',
                              ).format(widget.comment.createdAt),
                              style: TextStyle(
                                color: subTextColor,
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            if (!widget.isChild && widget.childCount > 0)
                              Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.comment_outlined,
                                      color: widget.darkStyle
                                          ? Colors.grey
                                          : Colors.white70,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${widget.childCount}",
                                      style: TextStyle(
                                        color: subTextColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            InkWell(
                              onTap: _isSubmittingLike ? null : toggleLike,
                              borderRadius: BorderRadius.circular(20),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isLike
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isLike
                                        ? Colors.red
                                        : (widget.darkStyle
                                              ? Colors.grey
                                              : Colors.white70),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "$likeCount",
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
                        // 展开/收起子评论按钮
                        if (widget.comment.childCount > 0)
                          TextButton(
                            onPressed: widget.onToggleExpand,
                            child: Text(
                              "${widget.expanded ? translate("collapse") : translate("expand")} ${widget.comment.childCount} ${translate("replies")}",
                              style: TextStyle(color: replyColor, fontSize: 13),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (widget.expanded && widget.childComments != null)
          widget.childComments!,
      ],
    );
  }
}
