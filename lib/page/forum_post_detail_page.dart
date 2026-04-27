import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:live_app/config/storage_config.dart';
import 'package:live_app/constants/ad_placement.dart';
import 'package:live_app/database/download_database.dart';
import 'package:live_app/models/userinfo.dart';
import 'package:live_app/provider/ad_provider.dart';
import 'package:live_app/provider/behavior_tracker_provider.dart';
import 'package:live_app/provider/download_video_provider.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/widgets/ad_banner_carousel.dart';
import 'package:live_app/widgets/download_button.dart';
import 'package:live_app/widgets/empty_widget.dart';
import 'package:live_app/widgets/vip_badge.dart';

import '../models/forum_attachment.dart';
import '../models/forum_comment.dart';
import '../models/forum_post.dart';
import '../provider/api_provider.dart';
import '../provider/forum_comments_provider.dart';
import '../provider/post_detail_provider.dart';
import '../provider/selected_post_provider.dart';
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
  UserInfo? _userInfo;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  ForumComment? _replyingTo;
  bool _bannerClosed = false;

  ForumPost? forumPost;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      getUserFromCache();
      ref
          .read(adListProvider(AdPlacement.communityLarge).notifier)
          .fetch(refresh: true);
    });
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

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> getUserFromCache() async {
    final data = await StorageService.instance.getValue("user_info");
    if (data != null && data.isNotEmpty) {
      final map = data is String ? jsonDecode(data) : data;
      setState(() {
        _userInfo = UserInfo.fromJson(map);
      });
    }
  }

  void checkLogin() {
    if (_userInfo == null || _userInfo!.isVisitor) {}
  }

  String translate(String key) =>
      ref.read(i18nNotifierProvider.notifier).translate(key);

  void _openGallery(
    List<ForumAttachment> attachments,
    ForumAttachment target,
    ForumPost post,
  ) {
    ref.read(selectedPostProvider.notifier).state = post;
    debugPrint("selectedPostProvider: ${post.title}");
    final filtered = attachments
        .where((a) => a.fileType == 'image' || a.fileType == 'video')
        .toList();

    filtered.sort((a, b) {
      if (a.fileType == b.fileType) return 0;
      return a.fileType == 'image' ? -1 : 1;
    });

    final isVideoLocked =
        post.price > 0 &&
        !ref.hasPermission(Permission.accessPostsFree) &&
        !post.isBought;

    final items = filtered.map((a) {
      final isVideo = a.fileType == 'video';
      return GalleryItem(
        url: a.fileUrl,
        isVideo: isVideo,
        isLocked: isVideo && isVideoLocked,
        thumbnailUrl: isVideo ? a.thumbnailUrl : null,
        encryptionKey: a.encryptionKey,
        price: post.price,
        contentId: post.id,
        contentTitle: post.title,
        contentType: 'posts',
      );
    }).toList();

    final index = filtered.indexWhere((a) => a.id == target.id);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GalleryPage(
          items: items,
          initialIndex: index >= 0 ? index : 0,
          onPurchaseSuccess: () {
            ref
                .read(postDetailProvider(widget.postId).notifier)
                .loadPostDetail(widget.postId);
          },
        ),
      ),
    );
  }

  Widget _buildContent(ForumPost? post) {
    if (post == null) {
      return Center(child: CircularProgressIndicator());
    }
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
                  ref
                      .read(postDetailProvider(widget.postId).notifier)
                      .userPostInterest(interactionType: "favorite");
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
          Row(
            children: [
              Text(
                DateFormat('yyyy-MM-dd  HH:mm').format(post.createdAt),
                style: const TextStyle(color: Colors.white60, fontSize: 14),
              ),
              Spacer(),
              // if (post.price > 0) PriceTag(basePrice: post.price),
            ],
          ),

          const SizedBox(height: 20),
          Text(
            post.description,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              height: 1.5,
            ),
          ),

          // 分离图片和视频
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
                              onTap: () =>
                                  _openGallery(post.attachments!, img, post),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: img.fileUrl.isNotEmpty
                                        ? EncryptedImage(
                                            url: img.fileUrl,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            color: Colors.grey.shade500,
                                            child: Icon(
                                              Icons.broken_image,
                                              size: 48,
                                              color: Colors.white70,
                                            ),
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
                                    onTap: () => _openGallery(
                                      post.attachments!,
                                      img,
                                      post,
                                    ),
                                    child: Container(
                                      width: 120,
                                      margin: const EdgeInsets.only(right: 8),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: img.fileUrl.isNotEmpty
                                            ? EncryptedImage(
                                                url: img.fileUrl,
                                                fit: BoxFit.cover,
                                                width: 120,
                                                height: 120,
                                              )
                                            : Container(
                                                color: Colors.grey.shade500,
                                                child: Icon(
                                                  Icons.broken_image,
                                                  size: 48,
                                                  color: Colors.white70,
                                                ),
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
                                  _openGallery(post.attachments!, video, post),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Stack(
                                  children: [
                                    AspectRatio(
                                      aspectRatio: 16 / 9,
                                      child: EncryptedImage(
                                        url: (video.thumbnailUrl ?? '').isEmpty
                                            ? 'https://image2url.com/images/1763732916680-117f5b5d-bac4-4362-8158-9549624f8fa4.jpg'
                                            : video.thumbnailUrl!,
                                        fit: BoxFit.cover,
                                        errorWidget: Image.network(
                                          'https://image2url.com/images/1763732916680-117f5b5d-bac4-4362-8158-9549624f8fa4.jpg',
                                          fit: BoxFit.cover,
                                        ),
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
                                    if (!kIsWeb)
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: StreamBuilder<Download?>(
                                          stream: ref
                                              .watch(offlineRepoProvider)
                                              .db
                                              .watchById(video.id.toString()),
                                          builder: (context, snapshot) {
                                            final existing = snapshot.data;
                                            final localPath =
                                                existing?.localPath;
                                            final fileExists = localPath != null
                                                ? File(localPath).existsSync()
                                                : false;

                                            if (existing == null) {
                                              return DownloadButton(
                                                attachment: video,
                                                forumPost: post,
                                                filename:
                                                    "video_${video.id}.mp4",
                                              );
                                            }

                                            switch (existing.status) {
                                              case "completed":
                                                if (fileExists) {
                                                  return const Icon(
                                                    Icons.download_done,
                                                    color: Colors.white,
                                                    size: 28.0,
                                                  );
                                                } else {
                                                  return DownloadButton(
                                                    attachment: video,
                                                    forumPost: post,
                                                    filename:
                                                        "video_${video.id}.mp4",
                                                  );
                                                }

                                              case "paused":
                                                return IconButton(
                                                  icon: const Icon(
                                                    Icons.play_arrow,
                                                    color: Colors.white,
                                                  ),
                                                  onPressed: () async {
                                                    final repo = ref.read(
                                                      offlineRepoProvider,
                                                    );
                                                    final i18nNotifier = ref
                                                        .read(
                                                          i18nNotifierProvider
                                                              .notifier,
                                                        );
                                                    await repo.resumeDownload(
                                                      id: video.id.toString(),
                                                      translate: i18nNotifier
                                                          .translate,
                                                    );
                                                  },
                                                );

                                              case "failed":
                                                return IconButton(
                                                  icon: const Icon(
                                                    Icons.refresh,
                                                    color: Colors.red,
                                                  ),
                                                  onPressed: () async {
                                                    final repo = ref.read(
                                                      offlineRepoProvider,
                                                    );
                                                    final i18nNotifier = ref
                                                        .read(
                                                          i18nNotifierProvider
                                                              .notifier,
                                                        );
                                                    await repo.downloadResource(
                                                      id: video.id.toString(),
                                                      filename:
                                                          "video_${video.id}.mp4",
                                                      translate: i18nNotifier
                                                          .translate,
                                                    );
                                                  },
                                                );

                                              case "cancelled":
                                                return DownloadButton(
                                                  attachment: video,
                                                  forumPost: post,
                                                  filename:
                                                      "video_${video.id}.mp4",
                                                );

                                              default:
                                                return DownloadButton(
                                                  attachment: video,
                                                  forumPost: post,
                                                  filename:
                                                      "video_${video.id}.mp4",
                                                );
                                            }
                                          },
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
                                    onTap: () => _openGallery(
                                      post.attachments!,
                                      video,
                                      post,
                                    ),
                                    child: Container(
                                      width: 160,
                                      margin: const EdgeInsets.only(right: 8),
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: EncryptedImage(
                                              url:
                                                  video.thumbnailUrl == null ||
                                                      video.thumbnailUrl == ""
                                                  ? "https://image2url.com/images/1763732916680-117f5b5d-bac4-4362-8158-9549624f8fa4.jpg"
                                                  : video.thumbnailUrl!,
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
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: StreamBuilder<Download?>(
                                              stream: ref
                                                  .watch(offlineRepoProvider)
                                                  .db
                                                  .watchById(
                                                    video.id.toString(),
                                                  ),
                                              builder: (context, snapshot) {
                                                final existing = snapshot.data;
                                                final localPath =
                                                    existing?.localPath;
                                                final fileExists =
                                                    localPath != null
                                                    ? File(
                                                        localPath,
                                                      ).existsSync()
                                                    : false;

                                                if (existing == null) {
                                                  return DownloadButton(
                                                    attachment: video,
                                                    forumPost: post,
                                                    filename:
                                                        "video_${video.id}.mp4",
                                                  );
                                                }

                                                switch (existing.status) {
                                                  case "completed":
                                                    if (fileExists) {
                                                      return const Icon(
                                                        Icons.download_done,
                                                        color: Colors.white,
                                                        size: 28.0,
                                                      );
                                                    } else {
                                                      return DownloadButton(
                                                        attachment: video,
                                                        forumPost: post,
                                                        filename:
                                                            "video_${video.id}.mp4",
                                                      );
                                                    }

                                                  case "paused":
                                                    return IconButton(
                                                      icon: const Icon(
                                                        Icons.play_arrow,
                                                        color: Colors.white,
                                                      ),
                                                      onPressed: () async {
                                                        final repo = ref.read(
                                                          offlineRepoProvider,
                                                        );
                                                        final i18nNotifier = ref
                                                            .read(
                                                              i18nNotifierProvider
                                                                  .notifier,
                                                            );
                                                        await repo
                                                            .resumeDownload(
                                                              id: video.id
                                                                  .toString(),
                                                              translate:
                                                                  i18nNotifier
                                                                      .translate,
                                                            );
                                                      },
                                                    );

                                                  case "failed":
                                                    return IconButton(
                                                      icon: const Icon(
                                                        Icons.refresh,
                                                        color: Colors.red,
                                                      ),
                                                      onPressed: () async {
                                                        final repo = ref.read(
                                                          offlineRepoProvider,
                                                        );
                                                        final i18nNotifier = ref
                                                            .read(
                                                              i18nNotifierProvider
                                                                  .notifier,
                                                            );
                                                        await repo.downloadResource(
                                                          id: video.id
                                                              .toString(),
                                                          filename:
                                                              "video_${video.id}.mp4",
                                                          translate:
                                                              i18nNotifier
                                                                  .translate,
                                                        );
                                                      },
                                                    );

                                                  case "cancelled":
                                                    return DownloadButton(
                                                      attachment: video,
                                                      forumPost: post,
                                                      filename:
                                                          "video_${video.id}.mp4",
                                                    );

                                                  default:
                                                    return DownloadButton(
                                                      attachment: video,
                                                      forumPost: post,
                                                      filename:
                                                          "video_${video.id}.mp4",
                                                    );
                                                }
                                              },
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
                      // trackLike();
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
              Text(
                ref.read(i18nNotifierProvider.notifier).translate('comment'),
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
          (post.commentCount < 1)
              ? EmptyWidget(
                  icon: Icons.message_outlined,
                  message: ref
                      .read(i18nNotifierProvider.notifier)
                      .translate("noCommentsYet"),
                )
              : ForumCommentsList(postId: post.id, onReply: _handleReply),
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
    final adState = ref.watch(adListProvider(AdPlacement.communityLarge));
    final post = state.post;
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);

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
                    if (post?.user != null) {
                      toUserDetailPage(
                        context: context,
                        ref: ref,
                        userId: post?.user?.id,
                        url: post?.user?.avatar,
                        nickname: post?.user?.nickname,
                      );
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              post?.user?.nickname ??
                                  ref
                                      .read(i18nNotifierProvider.notifier)
                                      .translate('anonymousUser'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          VipBadge(
                            vip: post?.user?.vip,
                            vipId: post?.user?.vipId,
                          ),
                        ],
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

              FollowButton(userId: post?.userId ?? ""),
            ],
          ),
          backgroundColor: Colors.black,
        ),
        body: Column(
          children: [
            if (adState.list.isNotEmpty && !_bannerClosed) ...[
              const SizedBox(height: 8),
              AdBannerCarousel(
                ads: adState.list,
                onClose: () => setState(() => _bannerClosed = true),
              ),
              const SizedBox(height: 8),
            ],
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
                        "${translate("error")}：${state.error}",
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  return _buildContent(post);
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

                  if (resp.data != null) {
                    ref.trackComment();
                  }

                  // resp.data 是 ForumComment
                  final newComment = resp.data;

                  // 清除回复对象
                  setState(() => _replyingTo = null);

                  // provider 追加新评论
                  ref
                      .read(forumCommentsProvider(widget.postId).notifier)
                      .addComment(newComment);

                  ref
                      .read(postDetailProvider(widget.postId).notifier)
                      .userPostInterest(interactionType: "comment");

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
