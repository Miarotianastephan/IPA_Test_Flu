import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:live_app/widgets/empty_retry.dart';

import '../api/services/user_service.dart';
import '../models/forum_attachment.dart';
import '../models/forum_comment.dart';
import '../models/forum_post.dart';
import '../provider/api_provider.dart';
import '../provider/forum_comments_provider.dart';
import '../provider/post_detail_provider.dart';
import '../utils/utils.dart';
import '../widgets/comment/comment_input_bar.dart';
import '../widgets/encrypted_image.dart';
import '../widgets/follow_button.dart';
import '../widgets/forum/forum_comment_list.dart';
import 'gallery_page.dart';

class ForumPostDetailPage extends ConsumerStatefulWidget {
  final int postId;

  const ForumPostDetailPage({super.key, required this.postId});

  @override
  ConsumerState<ForumPostDetailPage> createState() =>
      _ForumPostDetailPageState();
}

class _ForumPostDetailPageState extends ConsumerState<ForumPostDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  ForumComment? _replyingTo;
  late final UserService userService;

  @override
  void initState() {
    super.initState();
    userService = ref.read(userServiceProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 加载帖子详情
      ref
          .read(postDetailProvider(widget.postId).notifier)
          .loadPostDetail(widget.postId);

      ref.read(forumCommentsProvider(widget.postId).notifier).refresh();
    });

    _scrollController.addListener(() {
      final state = ref.read(forumCommentsProvider(widget.postId));

      if (!state.loading &&
          !state.finished &&
          _scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200) {
        ref.read(forumCommentsProvider(widget.postId).notifier).loadMore();
      }
    });
  }

  void _openGallery(List<ForumAttachment> attachments, ForumAttachment target) {
    final filtered = attachments
        .where((a) => a.fileType == 'image' || a.fileType == 'video')
        .toList();

    filtered.sort((a, b) {
      if (a.fileType == b.fileType) return 0;
      return a.fileType == 'image' ? -1 : 1;
    });

    final items = filtered.map((a) {
      return GalleryItem(url: a.fileUrl, isVideo: a.fileType == 'video');
    }).toList();

    final index = filtered.indexWhere((a) => a.id == target.id);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            GalleryPage(items: items, initialIndex: index >= 0 ? index : 0),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ForumPost post) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  post.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  post.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                  color: post.isLiked ? Colors.lightBlueAccent : Colors.white70,
                  size: 22,
                ),
                onPressed: () {
                  ref
                      .read(postDetailProvider(widget.postId).notifier)
                      .toggleLike();
                },
              ),
              IconButton(
                icon: Icon(
                  post.isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: post.isFavorited ? Colors.redAccent : Colors.white70,
                  size: 22,
                ),
                onPressed: () {
                  ref
                      .read(postDetailProvider(widget.postId).notifier)
                      .toggleFavorite();
                },
              ),
              IconButton(
                icon: Icon(
                  (post.isDownvoted ?? false)
                      ? Icons.thumb_down
                      : Icons.thumb_down_outlined,
                  color: (post.isDownvoted ?? false)
                      ? Colors.orangeAccent
                      : Colors.white70,
                  size: 22,
                ),
                onPressed: () {
                  ref
                      .read(postDetailProvider(widget.postId).notifier)
                      .toggleDownvote();
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            DateFormat('yyyy-MM-dd  HH:mm').format(post.createdAt),
            style: const TextStyle(color: Colors.white60, fontSize: 14),
          ),
          const SizedBox(height: 20),
          Text(
            post.content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              height: 1.5,
            ),
          ),
          // ---- 分离图片和视频 ----
          if (post.attachments != null && post.attachments!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //                 图片区域
                  Builder(
                    builder: (_) {
                      final images = post.attachments!
                          .where((a) => a.fileType == 'image')
                          .toList();

                      if (images.isEmpty) return const SizedBox();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...images.take(3).map((img) {
                            return GestureDetector(
                              onTap: () => _openGallery(post.attachments!, img),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      img.fileUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),

                          if (images.length > 3)
                            SizedBox(
                              height: 120,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: images.skip(3).map((img) {
                                  return GestureDetector(
                                    onTap: () =>
                                        _openGallery(post.attachments!, img),
                                    child: Container(
                                      width: 120,
                                      margin: const EdgeInsets.only(right: 8),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          img.fileUrl,
                                          fit: BoxFit.cover,
                                          width: 120,
                                          height: 120,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),

                          const SizedBox(height: 20),
                        ],
                      );
                    },
                  ),

                  //                 视频区域
                  Builder(
                    builder: (_) {
                      final videos = post.attachments!
                          .where((a) => a.fileType == 'video')
                          .toList();

                      if (videos.isEmpty) return const SizedBox();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...videos.take(3).map((video) {
                            return GestureDetector(
                              onTap: () =>
                                  _openGallery(post.attachments!, video),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Stack(
                                  children: [
                                    AspectRatio(
                                      aspectRatio: 16 / 9,
                                      child: Image.network(
                                        video.thumbnailUrl ?? "",
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const Positioned.fill(
                                      child: Center(
                                        child: Icon(
                                          Icons.play_circle_fill,
                                          color: Colors.white70,
                                          size: 50,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),

                          if (videos.length > 3)
                            SizedBox(
                              height: 120,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: videos.skip(3).map((video) {
                                  return GestureDetector(
                                    onTap: () =>
                                        _openGallery(post.attachments!, video),
                                    child: Container(
                                      width: 160,
                                      margin: const EdgeInsets.only(right: 8),
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.network(
                                              video.thumbnailUrl ?? "",
                                              fit: BoxFit.cover,
                                              width: 160,
                                              height: 120,
                                            ),
                                          ),
                                          const Positioned.fill(
                                            child: Center(
                                              child: Icon(
                                                Icons.play_circle_fill,
                                                color: Colors.white70,
                                                size: 40,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  const Icon(Icons.visibility, color: Colors.white70, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    post.viewCount.toString(),
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      post.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                      color: post.isLiked
                          ? Colors.lightBlueAccent
                          : Colors.white70,
                      size: 22,
                    ),
                    onPressed: () {
                      ref
                          .read(postDetailProvider(widget.postId).notifier)
                          .toggleLike();
                    },
                  ),
                  Text(
                    post.likeCount.toString(),
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      post.isFavorited ? Icons.favorite : Icons.favorite_border,
                      color: post.isFavorited
                          ? Colors.redAccent
                          : Colors.white70,
                      size: 22,
                    ),
                    onPressed: () {
                      ref
                          .read(postDetailProvider(widget.postId).notifier)
                          .toggleFavorite();
                    },
                  ),
                  Text(
                    post.favoriteCount.toString(),
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      (post.isDownvoted ?? false)
                          ? Icons.thumb_down
                          : Icons.thumb_down_outlined,
                      color: (post.isDownvoted ?? false)
                          ? Colors.orangeAccent
                          : Colors.white70,
                      size: 22,
                    ),
                    onPressed: () {
                      ref
                          .read(postDetailProvider(widget.postId).notifier)
                          .toggleDownvote();
                    },
                  ),
                  Text(
                    post.dislikeCount.toString(),
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              const Text(
                "评论",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "(${post.commentCount})",
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ForumCommentsList(postId: post.id, onReply: _handleReply),
        ],
      ),
    );
  }

  /// 自动滚动到最新评论
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// 点击回复评论时
  void _handleReply(ForumComment comment) {
    setState(() => _replyingTo = comment);

    // 自动聚焦输入框
    Future.delayed(const Duration(milliseconds: 50), () {
      _focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postDetailProvider(widget.postId));
    final post = state.post;

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Row(
            children: [
              UserAvatar(
                userId: post?.user?.id,
                url: post?.user?.avatar,
                nickname: post?.user?.nickname,
                size: 28,
              ),
              const SizedBox(width: 10),

              Expanded(
                child: GestureDetector(
                  onTap: () {
                    toUserDetailPage(
                      context: context,
                      userId: post?.user?.id,
                      url: post?.user?.avatar,
                      nickname: post?.user?.nickname,
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${post?.user?.nickname}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        post?.user?.bio ?? "",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              FollowButton(
                isFollowed: post?.user?.isFollowed ?? false,
                onPressed: (v) async {
                  await ref
                      .read(postDetailProvider(widget.postId).notifier)
                      .toggleFollow();
                },
              ),
            ],
          ),
          backgroundColor: Colors.black,
        ),
        body: Column(
          children: [
            Expanded(
              child: Builder(
                builder: (_) {
                  if (state.loading) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }

                  if (state.error != null) {
                    return Center(
                      child: Text(
                        "error：${state.error}",
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (post == null) {
                    return EmptyWithRetry(
                      onRetry: () {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ref
                              .read(postDetailProvider(widget.postId).notifier)
                              .loadPostDetail(widget.postId);
                        });
                      },
                    );
                  }

                  return _buildContent(context, post);
                },
              ),
            ),

            /// ---- 底部评论输入框 ----
            Container(
              color: Colors.black,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: CommentInputBar(
                controller: _commentController,
                replyingToName: _replyingTo?.commentUser?.nickname,
                onCancelReply: () {
                  setState(() => _replyingTo = null);
                },
                onSend: (content) async {
                  final service = ref.read(forumServiceProvider);

                  // --- 发评论 ---
                  final resp = await service.comment(
                    widget.postId,
                    content,
                    parentId: _replyingTo?.id,
                  );

                  // resp.data 是 ForumComment
                  final newComment = resp.data;

                  // 清除回复对象
                  setState(() => _replyingTo = null);

                  // provider 追加新评论
                  ref
                      .read(forumCommentsProvider(widget.postId).notifier)
                      .addComment(newComment);

                  // 更新贴子评论数
                  ref
                      .read(postDetailProvider(widget.postId).notifier)
                      .increaseCommentCount();

                  //  自动滚动到最新评论
                  _scrollToBottom();
                },
                darkStyle: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
