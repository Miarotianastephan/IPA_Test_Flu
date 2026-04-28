import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/database/download_database.dart';
import 'package:live_app/models/base_list_state.dart';
import 'package:live_app/models/forum_post.dart';
import 'package:live_app/models/userinfo.dart';
import 'package:live_app/models/video_list_state.dart';
import 'package:live_app/provider/app_config_provider.dart';
import 'package:live_app/provider/domain_provider.dart';
import 'package:live_app/provider/download_video_provider.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/provider/my_post_providers.dart' as my_post;
import 'package:live_app/provider/my_video_providers.dart' as my_video;
import 'package:live_app/provider/purchased_post_provider.dart';
import 'package:live_app/provider/purchased_video_provider.dart';
import 'package:live_app/provider/user_post_list_provider.dart' as user_post;
import 'package:live_app/provider/user_videos_provider.dart' as user_video;
import 'package:live_app/utils/app_lang_version_utils.dart';
import 'package:live_app/widgets/empty_widget.dart';
import 'package:live_app/widgets/encrypted_image.dart';
import 'package:live_app/widgets/general_post_tab.dart';
import 'package:live_app/widgets/general_video_tab.dart';
import 'package:live_app/widgets/profile/downloaded_list_item.dart';
import 'package:live_app/widgets/profile/downloaded_video_screen_page.dart';
import 'package:url_launcher/url_launcher.dart';

class _InnerVideoPostTab extends ConsumerStatefulWidget {
  final VideoListState videoState;
  final BaseListState<ForumPost> postState;
  final dynamic videoProvider;
  final VoidCallback onFetchVideos;
  final VoidCallback onLoadMoreVideos;
  final VoidCallback onFetchPosts;
  final VoidCallback onLoadMorePosts;

  const _InnerVideoPostTab({
    required this.videoState,
    required this.postState,
    required this.videoProvider,
    required this.onFetchVideos,
    required this.onLoadMoreVideos,
    required this.onFetchPosts,
    required this.onLoadMorePosts,
  });

  @override
  ConsumerState<_InnerVideoPostTab> createState() => _InnerVideoPostTabState();
}

class _InnerVideoPostTabState extends ConsumerState<_InnerVideoPostTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _videoLoaded = false;
  bool _postLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {});
      if (_tabController.index == 1 && !_postLoaded) {
        widget.onFetchPosts();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      widget.onFetchVideos();
    });
  }

  @override
  void didUpdateWidget(_InnerVideoPostTab old) {
    super.didUpdateWidget(old);
    if (old.videoState.loading && !widget.videoState.loading) {
      setState(() => _videoLoaded = true);
    }
    if (old.postState.loading && !widget.postState.loading) {
      setState(() => _postLoaded = true);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final i18n = ref.read(i18nNotifierProvider.notifier);

    return Column(
      children: [
        Container(
          color: Colors.black,
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(text: i18n.translate('video')),
              Tab(text: i18n.translate('post')),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              GeneralVideoTab(
                finished: widget.videoState.finished,
                onRefresh: widget.onFetchVideos,
                onLoadMore: widget.onLoadMoreVideos,
                isLoaded: _videoLoaded,
                loading: widget.videoState.loading,
                results: widget.videoState.list,
                provider: widget.videoProvider,
              ),
              GeneralPostTab(
                finished: widget.postState.finished,
                onRefresh: widget.onFetchPosts,
                onLoadMore: widget.onLoadMorePosts,
                isLoaded: _postLoaded,
                loading: widget.postState.loading,
                results: widget.postState.list,
                showCategory: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ContentUser extends ConsumerStatefulWidget {
  final UserInfo user;

  const ContentUser({super.key, required this.user});

  @override
  ConsumerState<ContentUser> createState() => _ContentUserState();
}

class _ContentUserState extends ConsumerState<ContentUser> {
  void _fetchVideos() {
    ref
        .read(user_video.userVideoListProvider(widget.user.id).notifier)
        .fetch(refresh: true);
  }

  void _loadMoreVideos() {
    final prov = user_video.userVideoListProvider(widget.user.id);
    final state = ref.read(prov);
    if (state.loading || state.finished) return;
    ref.read(prov.notifier).fetch(refresh: false);
  }

  void _fetchPosts() {
    ref
        .read(user_post.userPostListProvider(widget.user.id).notifier)
        .fetch(refresh: true);
  }

  void _loadMorePosts() {
    final prov = user_post.userPostListProvider(widget.user.id);
    final state = ref.read(prov);
    if (state.loading || state.finished) return;
    ref.read(prov.notifier).fetch(refresh: false);
  }

  @override
  Widget build(BuildContext context) {
    final videoState = ref.watch(
      user_video.userVideoListProvider(widget.user.id),
    );
    final postState = ref.watch(user_post.userPostListProvider(widget.user.id));

    return _InnerVideoPostTab(
      videoState: videoState,
      postState: postState,
      videoProvider: user_video.userVideoListProvider(widget.user.id),
      onFetchVideos: _fetchVideos,
      onLoadMoreVideos: _loadMoreVideos,
      onFetchPosts: _fetchPosts,
      onLoadMorePosts: _loadMorePosts,
    );
  }
}

class MyFavorite extends ConsumerStatefulWidget {
  const MyFavorite({super.key});

  @override
  ConsumerState<MyFavorite> createState() => _MyFavoriteState();
}

class _MyFavoriteState extends ConsumerState<MyFavorite> {
  void _fetchVideos() {
    final prov = my_video.userVideoListProvider(
      my_video.UserVideoListType.favorite,
    );
    ref.invalidate(prov);
    ref.read(prov.notifier).fetch(refresh: true);
  }

  void _loadMoreVideos() {
    final prov = my_video.userVideoListProvider(
      my_video.UserVideoListType.favorite,
    );
    final state = ref.read(prov);
    if (state.loading || state.finished) return;
    ref.read(prov.notifier).fetch(refresh: false);
  }

  void _fetchPosts() {
    ref
        .read(
          my_post
              .userPostListProvider(my_post.UserPostListType.favorite)
              .notifier,
        )
        .fetch(refresh: true);
  }

  void _loadMorePosts() {
    final prov = my_post.userPostListProvider(
      my_post.UserPostListType.favorite,
    );
    final state = ref.read(prov);
    if (state.loading || state.finished) return;
    ref.read(prov.notifier).fetch(refresh: false);
  }

  @override
  Widget build(BuildContext context) {
    final videoState = ref.watch(
      my_video.userVideoListProvider(my_video.UserVideoListType.favorite),
    );
    final postState = ref.watch(
      my_post.userPostListProvider(my_post.UserPostListType.favorite),
    );

    return _InnerVideoPostTab(
      videoState: videoState,
      postState: postState,
      videoProvider: my_video.userVideoListProvider(
        my_video.UserVideoListType.favorite,
      ),
      onFetchVideos: _fetchVideos,
      onLoadMoreVideos: _loadMoreVideos,
      onFetchPosts: _fetchPosts,
      onLoadMorePosts: _loadMorePosts,
    );
  }
}

class WatchHistory extends ConsumerStatefulWidget {
  const WatchHistory({super.key});

  @override
  ConsumerState<WatchHistory> createState() => _WatchHistoryState();
}

class _WatchHistoryState extends ConsumerState<WatchHistory> {
  void _fetchVideos() {
    ref
        .read(
          my_video
              .userVideoListProvider(my_video.UserVideoListType.history)
              .notifier,
        )
        .fetch(refresh: true);
  }

  void _loadMoreVideos() {
    final prov = my_video.userVideoListProvider(
      my_video.UserVideoListType.history,
    );
    final state = ref.read(prov);
    if (state.loading || state.finished) return;
    ref.read(prov.notifier).fetch(refresh: false);
  }

  void _fetchPosts() {
    ref
        .read(
          my_post
              .userPostListProvider(my_post.UserPostListType.history)
              .notifier,
        )
        .fetch(refresh: true);
  }

  void _loadMorePosts() {
    final prov = my_post.userPostListProvider(my_post.UserPostListType.history);
    final state = ref.read(prov);
    if (state.loading || state.finished) return;
    ref.read(prov.notifier).fetch(refresh: false);
  }

  @override
  Widget build(BuildContext context) {
    final videoState = ref.watch(
      my_video.userVideoListProvider(my_video.UserVideoListType.history),
    );
    final postState = ref.watch(
      my_post.userPostListProvider(my_post.UserPostListType.history),
    );

    return _InnerVideoPostTab(
      videoState: videoState,
      postState: postState,
      videoProvider: my_video.userVideoListProvider(
        my_video.UserVideoListType.history,
      ),
      onFetchVideos: _fetchVideos,
      onLoadMoreVideos: _loadMoreVideos,
      onFetchPosts: _fetchPosts,
      onLoadMorePosts: _loadMorePosts,
    );
  }
}

class ContentLiked extends ConsumerStatefulWidget {
  const ContentLiked({super.key});

  @override
  ConsumerState<ContentLiked> createState() => _ContentLikedState();
}

class _ContentLikedState extends ConsumerState<ContentLiked> {
  void _fetchVideos() {
    final prov = my_video.userVideoListProvider(
      my_video.UserVideoListType.like,
    );
    ref.invalidate(prov);
    ref.read(prov.notifier).fetch(refresh: true);
  }

  void _loadMoreVideos() {
    final prov = my_video.userVideoListProvider(
      my_video.UserVideoListType.like,
    );
    final state = ref.read(prov);
    if (state.loading || state.finished) return;
    ref.read(prov.notifier).fetch(refresh: false);
  }

  void _fetchPosts() {
    ref
        .read(
          my_post.userPostListProvider(my_post.UserPostListType.liked).notifier,
        )
        .fetch(refresh: true);
  }

  void _loadMorePosts() {
    final prov = my_post.userPostListProvider(my_post.UserPostListType.liked);
    final state = ref.read(prov);
    if (state.loading || state.finished) return;
    ref.read(prov.notifier).fetch(refresh: false);
  }

  @override
  Widget build(BuildContext context) {
    final videoState = ref.watch(
      my_video.userVideoListProvider(my_video.UserVideoListType.like),
    );
    final postState = ref.watch(
      my_post.userPostListProvider(my_post.UserPostListType.liked),
    );

    return _InnerVideoPostTab(
      videoState: videoState,
      postState: postState,
      videoProvider: my_video.userVideoListProvider(
        my_video.UserVideoListType.like,
      ),
      onFetchVideos: _fetchVideos,
      onLoadMoreVideos: _loadMoreVideos,
      onFetchPosts: _fetchPosts,
      onLoadMorePosts: _loadMorePosts,
    );
  }
}

class PurchasedContent extends ConsumerStatefulWidget {
  const PurchasedContent({super.key});

  @override
  ConsumerState<PurchasedContent> createState() => _PurchasedContentState();
}

class _PurchasedContentState extends ConsumerState<PurchasedContent> {
  void _fetchVideos() {
    ref.read(purchasedVideoProvider.notifier).fetch(refresh: true);
  }

  void _fetchPosts() {
    ref.read(purchasedPostProvider.notifier).fetch(refresh: true);
  }

  void _loadMoreVideos() {
    final state = ref.read(purchasedVideoProvider);
    if (state.loading || state.finished) return;
    ref.read(purchasedVideoProvider.notifier).fetch(refresh: false);
  }

  void _loadMorePosts() {
    final state = ref.read(purchasedPostProvider);
    if (state.loading || state.finished) return;
    ref.read(purchasedPostProvider.notifier).fetch(refresh: false);
  }

  @override
  Widget build(BuildContext context) {
    final videoState = ref.watch(purchasedVideoProvider);
    final postState = ref.watch(purchasedPostProvider);

    return _InnerVideoPostTab(
      videoState: videoState,
      postState: postState,
      videoProvider: purchasedVideoProvider,
      onFetchVideos: _fetchVideos,
      onLoadMoreVideos: _loadMoreVideos,
      onFetchPosts: _fetchPosts,
      onLoadMorePosts: _loadMorePosts,
    );
  }
}

class DownloadedContent extends ConsumerStatefulWidget {
  const DownloadedContent({super.key});

  @override
  ConsumerState<DownloadedContent> createState() => _DownloadedContentState();
}

class _DownloadedContentState extends ConsumerState<DownloadedContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isDeleteMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _deleteOne(String id) async {
    final repo = ref.read(offlineRepoProvider);
    await repo.cancelDownload(id);
    final int itemId = int.tryParse(id) ?? 0;
    ref.read(preparedProvider(itemId).notifier).state = false;
    ref.read(preparingProvider(itemId).notifier).state = false;
    ref.read(progressProvider(itemId).notifier).state = 0;
    ref.invalidate(isStorageSaturatedProvider);
    if (mounted) {
      final i18n = ref.read(i18nNotifierProvider.notifier);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(i18n.translate("contentDeleted"))));
    }
  }

  Future<void> _deleteAll() async {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(i18n.translate("confirmation")),
        content: Text(i18n.translate("confirmDeleteAll")),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              i18n.translate("cancel"),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              i18n.translate("delete"),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final repo = ref.read(offlineRepoProvider);
    await repo.deleteAll();
    ref.invalidate(preparedProvider);
    ref.invalidate(preparingProvider);
    ref.invalidate(progressProvider);
    ref.invalidate(isStorageSaturatedProvider);
    if (mounted) {
      setState(() => _isDeleteMode = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(i18n.translate("allContentDeleted"))),
      );
    }
  }

  void _playDownload(Download item) {
    final localPath = item.localPath;
    if (localPath != null && File(localPath).existsSync()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DownloadedVideoScreenPage(localPath: localPath),
        ),
      );
    } else {
      final i18n = ref.read(i18nNotifierProvider.notifier);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(i18n.translate("fileNotFound"))));
    }
  }

  int _statusPriority(String status) {
    switch (status) {
      case "downloading":
        return 0;
      case "paused":
        return 1;
      case "pending":
        return 2;
      case "failed":
        return 3;
      case "completed":
        return 4;
      case "cancelled":
        return 5;
      default:
        return 6;
    }
  }

  String _translateByCandidates(
    dynamic i18n,
    List<String> keys, {
    required String fallback,
  }) {
    for (final key in keys) {
      final translated = i18n.translate(key);
      if (translated != key && translated.trim().isNotEmpty) {
        return translated;
      }
    }
    return fallback;
  }

  String _statusLabel(String status, dynamic i18n) {
    switch (status) {
      case "downloading":
        return i18n.translate("downloadInProgress", fallback: "Downloading");
      case "paused":
        return _translateByCandidates(
            i18n,
            const [
              "downloadPaused",
              "paused",
              "pause",
            ],
            fallback: "Paused");
      case "completed":
        return i18n.translate("downloadComplete", fallback: "Completed");
      case "failed":
        return i18n.translate("loadFailed", fallback: "Failed");
      case "cancelled":
        return i18n.translate("cancel", fallback: "Cancelled");
      case "pending":
      default:
        return i18n.translate("loading", fallback: "Pending");
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case "downloading":
        return Colors.lightBlueAccent;
      case "paused":
        return Colors.orangeAccent;
      case "completed":
        return Colors.greenAccent;
      case "failed":
        return Colors.redAccent;
      case "cancelled":
        return Colors.grey;
      case "pending":
      default:
        return Colors.white70;
    }
  }

  IconData _primaryActionIcon(String status) {
    switch (status) {
      case "completed":
        return Icons.play_arrow_rounded;
      case "downloading":
        return Icons.pause_rounded;
      case "paused":
        return Icons.play_arrow_rounded;
      case "failed":
      case "cancelled":
        return Icons.refresh_rounded;
      case "pending":
      default:
        return Icons.download_rounded;
    }
  }

  String _primaryActionLabel(String status, dynamic i18n) {
    switch (status) {
      case "completed":
        return i18n.translate("play", fallback: "Play");
      case "downloading":
        return i18n.translate("pause", fallback: "Pause");
      case "paused":
        return i18n.translate("resume", fallback: "Resume");
      case "failed":
      case "cancelled":
        return i18n.translate("retry", fallback: "Retry");
      case "pending":
      default:
        return i18n.translate("download", fallback: "Download");
    }
  }

  bool _showSecondaryAction(String status) {
    return status == "downloading" ||
        status == "paused" ||
        status == "failed" ||
        status == "cancelled";
  }

  String _buildFilename(Download item) {
    return "video_${item.id}.mp4";
  }

  Future<void> _startOrRetryDownload(Download item, dynamic i18n) async {
    final repo = ref.read(offlineRepoProvider);
    await repo.downloadResource(
      id: item.id,
      filename: _buildFilename(item),
      translate: i18n.translate,
    );
  }

  Future<void> _resumeDownload(Download item, dynamic i18n) async {
    final repo = ref.read(offlineRepoProvider);
    await repo.resumeDownload(id: item.id, translate: i18n.translate);
  }

  Future<void> _pauseDownload(Download item) async {
    final repo = ref.read(offlineRepoProvider);
    await repo.pauseDownload(item.id);
  }

  Future<void> _cancelDownload(Download item) async {
    final repo = ref.read(offlineRepoProvider);
    await repo.cancelDownload(item.id);
    final int itemId = int.tryParse(item.id) ?? 0;
    ref.read(preparedProvider(itemId).notifier).state = false;
    ref.read(preparingProvider(itemId).notifier).state = false;
    ref.read(progressProvider(itemId).notifier).state = 0;
    ref.invalidate(isStorageSaturatedProvider);
  }

  Future<void> _handlePrimaryAction(Download item, dynamic i18n) async {
    switch (item.status) {
      case "completed":
        _playDownload(item);
        return;
      case "downloading":
        await _pauseDownload(item);
        return;
      case "paused":
        await _resumeDownload(item, i18n);
        return;
      case "failed":
      case "cancelled":
      case "pending":
      default:
        await _startOrRetryDownload(item, i18n);
        return;
    }
  }

  void _handleTileTap(Download item, dynamic i18n) {
    if (item.status == "completed") {
      _playDownload(item);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          i18n.translate(
            "downloadNotComplete",
            fallback: "Download not complete yet",
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    final downloadsAsync = ref.watch(downloadsStreamProvider);

    return downloadsAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
      error: (error, stackTrace) =>
          Center(child: EmptyWidget(message: i18n.translate("error"))),
      data: (items) {
        final allItems = [...items]..sort((a, b) {
            final comparePriority = _statusPriority(
              a.status,
            ).compareTo(_statusPriority(b.status));
            if (comparePriority != 0) return comparePriority;
            return b.createdAt.compareTo(a.createdAt);
          });
        final videos = allItems
            .where((d) => d.type == "short" || d.type == "long")
            .toList();
        final posts = allItems.where((d) => d.type == "forum").toList();
        final hasContent = videos.isNotEmpty || posts.isNotEmpty;

        return Column(
          children: [
            Container(
              color: Colors.black,
              child: Row(
                children: [
                  Expanded(
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.white,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white54,
                      tabs: [
                        Tab(text: i18n.translate('video')),
                        Tab(text: i18n.translate('post')),
                      ],
                    ),
                  ),
                  if (hasContent)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onSelected: (value) {
                        if (value == "delete_all") {
                          _deleteAll();
                        } else if (value == "delete_one") {
                          setState(() => _isDeleteMode = !_isDeleteMode);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: "delete_all",
                          child: Text(i18n.translate("deleteAll")),
                        ),
                        PopupMenuItem(
                          value: "delete_one",
                          child: Text(
                            _isDeleteMode
                                ? i18n.translate("cancelDeletion")
                                : i18n.translate("deleteVideo"),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDownloadList(videos, i18n),
                  _buildDownloadList(posts, i18n),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDownloadList(List<Download> items, dynamic i18n) {
    if (items.isEmpty) {
      return Center(child: EmptyWidget(message: i18n.translate("noContent")));
    }
    final bottomSafePadding = MediaQuery.of(context).padding.bottom + 84;
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(8, 8, 8, bottomSafePadding),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        return DownloadedListItem(
          item: item,
          isDeleteMode: _isDeleteMode,
          statusLabel: _statusLabel(item.status, i18n),
          statusColor: _statusColor(item.status),
          primaryActionLabel: _primaryActionLabel(item.status, i18n),
          primaryActionIcon: _primaryActionIcon(item.status),
          showSecondaryAction: _showSecondaryAction(item.status),
          onTap: () => _handleTileTap(item, i18n),
          onDelete: () => _deleteOne(item.id),
          onPrimaryAction: () {
            _handlePrimaryAction(item, i18n);
          },
          onSecondaryAction: _showSecondaryAction(item.status)
              ? () {
                  _cancelDownload(item);
                }
              : null,
        );
      },
    );
  }
}

class DownloadAppCard extends ConsumerWidget {
  const DownloadAppCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    final appConfig = ref.watch(appConfigProvider);
    final faviconUrl = appConfig.data?.faviconUrl ?? "";

    final landing = ref.read(domainProvider).domain?.landing;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 0, 0, 0),
                  Color.fromARGB(255, 0, 0, 0),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: EncryptedImage(
                      url: faviconUrl,
                      height: 72,
                      width: 72,
                      fit: BoxFit.cover,
                      errorWidget: Image.asset(
                        AppLangVersionUtils.getBackgroundLogoPath(),
                        height: 72,
                        width: 72,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  i18n.translate("downloadApp"),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  i18n.translate("downloadAppDesc"),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 8,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: landing == null
                      ? null
                      : () {
                          launchUrl(Uri.parse(landing));
                        },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.download_rounded, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        i18n.translate("download"),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
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
    );
  }
}
