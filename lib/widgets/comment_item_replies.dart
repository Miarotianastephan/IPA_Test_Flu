import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:live_app/config/storage_config.dart';
import 'package:live_app/models/userinfo.dart';
import 'package:live_app/provider/i18n_provider.dart';

import '../models/video_comment.dart';
import '../provider/api_provider.dart';
import 'encrypted_image.dart';
import 'vip_badge.dart';

class CommentItemReplies extends ConsumerStatefulWidget {
  final VideoComment comment;
  final void Function(VideoComment)? onClick;
  final bool darkStyle;

  const CommentItemReplies({
    super.key,
    required this.comment,
    this.onClick,
    this.darkStyle = true,
  });

  @override
  ConsumerState<CommentItemReplies> createState() => _CommentItemRepliesState();
}

class _CommentItemRepliesState extends ConsumerState<CommentItemReplies> {
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onClick != null
            ? () => widget.onClick!(widget.comment)
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserAvatar(
                userId: toUser?.id ?? user?.id,
                url: toUser?.avatar ?? user?.avatar,
                nickname: toUser?.nickname ?? user?.nickname,
                vip: toUser?.vip ?? user?.vip,
                size: 32,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            toUser?.nickname ??
                                user?.nickname ??
                                translate("unknownUser"),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        VipBadge(vip: toUser?.vip ?? user?.vip, size: 14),
                        if (toUser != null && user != null) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right,
                            size: 16,
                            color: subTextColor,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              user.nickname ?? "",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: replyColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          VipBadge(vip: user.vip, size: 14),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.comment.content,
                      style: TextStyle(color: textColor),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          DateFormat(
                            'yyyy-MM-dd  HH:mm',
                          ).format(widget.comment.createdAt),
                          style: TextStyle(color: subTextColor, fontSize: 12),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: _isSubmittingLike ? null : toggleLike,
                          borderRadius: BorderRadius.circular(20),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isLike ? Icons.favorite : Icons.favorite_border,
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
