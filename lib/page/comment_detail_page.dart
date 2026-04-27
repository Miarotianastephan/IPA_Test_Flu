import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:live_app/models/vip.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/widgets/vip_badge.dart';
import 'package:live_app/widgets/comment_item_replies.dart';

import '../api/services/video_service.dart';
import '../models/page_params.dart';
import '../models/video_comment.dart';
import '../provider/api_provider.dart';
import '../widgets/comment/comment_input_bar.dart';
import '../widgets/encrypted_image.dart';

class CommentDetailPage extends ConsumerStatefulWidget {
  final VideoComment parentComment;
  final String videoId;

  const CommentDetailPage({
    super.key,
    required this.parentComment,
    required this.videoId,
  });

  @override
  ConsumerState<CommentDetailPage> createState() => _CommentDetailPageState();
}

class _CommentDetailPageState extends ConsumerState<CommentDetailPage> {
  late final VideoService videoService;
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<VideoComment> childComments = [];
  bool _loading = false;
  bool _finished = false;
  int _page = 1;

  String? _replyingToName;
  Vip? _replyingToVip;

  @override
  void initState() {
    super.initState();
    videoService = ref.read(videoServiceProvider);
    _loadChildComments(refresh: true);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          !_loading &&
          !_finished) {
        _loadChildComments();
      }
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadChildComments({bool refresh = false}) async {
    if (_loading) return;

    setState(() => _loading = true);

    try {
      final nextPage = refresh ? 1 : _page + 1;
      final response = await videoService.videoChildCommentList(
        PageParams(page: nextPage),
        widget.parentComment.id,
      );

      final newList = (response.data?.list ?? [])
          .map((e) => VideoComment.fromJson(e.toJson()))
          .toList();

      final reversedList = newList.reversed.toList();

      setState(() {
        if (refresh) {
          childComments = reversedList;
          _page = 1;
        } else {
          childComments.addAll(reversedList);
          _page = nextPage;
        }

        _finished =
            response.data?.total != null &&
            childComments.length >= response.data!.total;
      });
    } catch (e, stackTrace) {
      throw Exception('Stack trace: $stackTrace');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _onReplyToChild(VideoComment comment) {
    setState(() {
      _replyingToName = comment.commentUser?.nickname;
      _replyingToVip = comment.commentUser?.vip;
    });
  }

  Future<void> _handleSendReply(String content) async {
    if (content.trim().isEmpty) return;

    try {
      final response = await videoService.commentVideo(
        widget.videoId,
        content,
        parentId: widget.parentComment.id,
      );

      final newComment = response.data!;

      setState(() {
        childComments.insert(0, newComment);

        _replyingToName = null;
        _replyingToVip = null;
      });

      _commentController.clear();

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
      _loadChildComments(refresh: true);
    } catch (e) {
      throw Exception('Erreur envoi réponse: $e');
    }
  }

  Widget _buildParentCommentHeader() {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    final user = widget.parentComment.commentUser;
    final toUser = widget.parentComment.commentToUser;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatar(
            userId: user?.id,
            url: user?.avatar,
            nickname: user?.nickname,
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
                        user?.nickname ?? i18n.translate('unknownUser'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    VipBadge(vip: user?.vip),
                    if (toUser != null) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          toUser.nickname ?? "",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.lightBlueAccent,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      VipBadge(vip: toUser.vip),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  widget.parentComment.content,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat(
                    'yyyy-MM-dd  HH:mm',
                  ).format(widget.parentComment.createdAt),
                  style: TextStyle(color: Colors.grey[300], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final i18n = ref.read(i18nNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          i18n.translate('replies'),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // Commentaire parent (header)
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              border: Border(
                bottom: BorderSide(color: Colors.grey[800]!, width: 1),
              ),
            ),
            child: _buildParentCommentHeader(),
          ),

          if (childComments.isNotEmpty || _loading)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                border: Border(
                  bottom: BorderSide(color: Colors.grey[800]!, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '${i18n.translate('replies')} (${widget.parentComment.childCount})',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: RefreshIndicator(
              color: Colors.white,
              backgroundColor: Colors.black,
              onRefresh: () => _loadChildComments(refresh: true),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: childComments.length + 1,
                itemBuilder: (context, index) {
                  if (index < childComments.length) {
                    return CommentItemReplies(
                      comment: childComments[index],
                      darkStyle: false,
                      onClick: _onReplyToChild,
                    );
                  }

                  if (_finished) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          i18n.translate('noMoreComments'),
                          style: const TextStyle(color: Colors.white70),
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

          SafeArea(
            top: false,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                border: Border(
                  top: BorderSide(color: Colors.grey[800]!, width: 0.5),
                ),
              ),
              child: CommentInputBar(
                controller: _commentController,
                replyingToName:
                    _replyingToName ??
                    widget.parentComment.commentUser?.nickname,
                replyingToVip:
                    _replyingToVip ?? widget.parentComment.commentUser?.vip,
                onCancelReply: () {
                  setState(() {
                    _replyingToName = null;
                    _replyingToVip = null;
                  });
                },
                darkStyle: false,
                onSend: _handleSendReply,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
