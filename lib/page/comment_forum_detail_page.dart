import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:live_app/api/services/forum_service.dart';
import 'package:live_app/l10n/app_localizations.dart';
import 'package:live_app/models/forum_comment.dart';
import 'package:live_app/models/page_params.dart';
import 'package:live_app/provider/api_provider.dart';
import 'package:live_app/widgets/comment/comment_input_bar.dart';
import 'package:live_app/widgets/encrypted_image.dart';
import 'package:live_app/widgets/forum/forum_comment_item.dart';

class CommentForumDetailPage extends ConsumerStatefulWidget {
  final ForumComment parentComment;
  final void Function(ForumComment comment)? onReply;

  const CommentForumDetailPage({
    super.key,
    required this.parentComment,
    this.onReply,
  });

  @override
  ConsumerState<CommentForumDetailPage> createState() =>
      _CommentForumDetailPageState();
}

class _CommentForumDetailPageState
    extends ConsumerState<CommentForumDetailPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _commentController = TextEditingController();

  late final ForumService forumService;
  List<ForumComment> childComments = [];
  bool _loading = false;
  bool _finished = false;
  int _page = 1;

  ForumComment? _replyingTo;

  @override
  void initState() {
    super.initState();
    forumService = ref.read(forumServiceProvider);
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
    _scrollController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadChildComments({bool refresh = false}) async {
    if (_loading) return;
    setState(() => _loading = true);

    try {
      final nextPage = refresh ? 1 : _page + 1;
      final resp = await forumService.commentChildren(
        PageParams(page: nextPage, limit: 20),
        widget.parentComment.id,
      );

      final newList = (resp.data?.list ?? [])
          .map((e) => ForumComment.fromJson(e.toJson()))
          .toList();

      setState(() {
        if (refresh) {
          childComments = newList;
          _page = 1;
        } else {
          childComments.addAll(newList);
          _page = nextPage;
        }

        _finished =
            resp.data?.total != null &&
            childComments.length >= resp.data!.total;
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _handleSendReply(String content) async {
    if (content.trim().isEmpty) return;

    try {
      final resp = await forumService.comment(
        widget.parentComment.postId,
        content,
        parentId: _replyingTo?.id ?? widget.parentComment.id,
      );

      final newComment = resp.data;

      setState(() {
        childComments.insert(0, newComment!);
        _replyingTo = null;
      });

      _commentController.clear();
      _scrollToBottom();

      _loadChildComments(refresh: true);
    } catch (e) {
      debugPrint('Erreur envoi réponse: $e');
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _buildParentCommentHeader() {
    final user = widget.parentComment.commentUser;
    final toUser = widget.parentComment.commentToUser;

    return Container(
      padding: const EdgeInsets.all(12),
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
                    Text(
                      user?.nickname ?? 'Unknown User',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (toUser != null) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        toUser.nickname,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlueAccent,
                        ),
                      ),
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
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          localizations.replies,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              border: Border(
                bottom: BorderSide(color: Colors.grey[800]!, width: 1),
              ),
            ),
            child: _buildParentCommentHeader(),
          ),
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
                  '${localizations.replies} (${widget.parentComment.childCount})',
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
                    return ForumCommentItem(
                      comment: childComments[index],
                      isChild: true,
                      darkStyle: false,
                      onReply: (comment) {
                        setState(() => _replyingTo = comment);
                      },
                    );
                  }

                  if (_finished) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          localizations.noMoreComments,
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
                    _replyingTo?.commentUser?.nickname ??
                    widget.parentComment.commentUser?.nickname,
                onCancelReply: () {
                  setState(() => _replyingTo = null);
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
