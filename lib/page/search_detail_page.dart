import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/i18n_provider.dart';

import '../models/forum_post.dart';
import '../models/userinfo.dart';
import '../models/video_info.dart';
import '../provider/search_post_list_provider.dart';
import '../provider/search_user_list_provider.dart';
import '../provider/search_video_list_provider.dart';
import '../widgets/general_post_tab.dart';
import '../widgets/general_user_tab.dart';
import '../widgets/general_video_tab.dart';

class SearchDetailPage extends ConsumerStatefulWidget {
  final String keyword;

  const SearchDetailPage({super.key, required this.keyword});

  @override
  ConsumerState<SearchDetailPage> createState() => _SearchDetailPageState();
}

class _SearchDetailPageState extends ConsumerState<SearchDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _videoRequested = false;
  bool _postRequested = false;
  bool _userRequested = false;

  SearchPostQueryParams get _postParams =>
      SearchPostQueryParams(keyword: widget.keyword);

  ({String keyword, String? sort, int? type}) get _videoParams =>
      (keyword: widget.keyword, sort: null, type: null);

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        return;
      }

      switch (_tabController.index) {
        case 0:
          _fetchVideosIfNeeded();
          break;
        case 1:
          _fetchPostsIfNeeded();
          break;
        case 2:
          _fetchUsersIfNeeded();
          break;
      }
    });

    // 初次加载视频
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 350));
      _fetchVideosIfNeeded();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _markVideoRequested() {
    if (_videoRequested) {
      return;
    }
    setState(() {
      _videoRequested = true;
    });
  }

  void _markPostRequested() {
    if (_postRequested) {
      return;
    }
    setState(() {
      _postRequested = true;
    });
  }

  void _markUserRequested() {
    if (_userRequested) {
      return;
    }
    setState(() {
      _userRequested = true;
    });
  }

  void _fetchVideosIfNeeded() {
    _markVideoRequested();
    _fetchVideos();
  }

  void _fetchPostsIfNeeded() {
    _markPostRequested();
    _fetchPosts();
  }

  void _fetchUsersIfNeeded() {
    _markUserRequested();
    _fetchUser();
  }

  void _fetchVideos() {
    ref
        .read(searchVideoListProvider(_videoParams).notifier)
        .fetch(refresh: true);
  }

  void _loadMoreVideos() {
    final notifier = ref.read(searchVideoListProvider(_videoParams).notifier);

    final state = ref.read(searchVideoListProvider(_videoParams));

    // 如果正在加载 或 已加载完所有数据，则不再继续
    if (state.loading || state.finished) return;

    notifier.fetch(refresh: false);
  }

  /// 加载帖子
  void _fetchPosts() {
    ref.read(searchPostListProvider(_postParams).notifier).fetch(refresh: true);
  }

  /// 帖子加载更多
  void _loadMorePosts() {
    final notifier = ref.read(searchPostListProvider(_postParams).notifier);

    final state = ref.read(searchPostListProvider(_postParams));

    // 如果正在加载 或 已加载完所有数据，则不再继续
    if (state.loading || state.finished) return;

    notifier.fetch(refresh: false);
  }

  void _fetchUser() {
    ref
        .read(searchUserListProvider(widget.keyword).notifier)
        .fetch(refresh: true);
  }

  void _loadMoreUsers() {
    final notifier = ref.read(searchUserListProvider(widget.keyword).notifier);
    final state = ref.read(searchUserListProvider(widget.keyword));
    if (state.loading || state.finished) return;
    notifier.fetch(refresh: false);
  }

  @override
  Widget build(BuildContext context) {
    const background = Colors.black;

    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "\"${widget.keyword}\"",
          style: const TextStyle(color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: [
            Tab(text: translate("video")),
            Tab(text: translate("post")),
            Tab(text: translate("user")),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const ClampingScrollPhysics(),
        children: [
          RepaintBoundary(
            child: _SearchVideoTabBody(
              provider: searchVideoListProvider(_videoParams),
              isRequested: _videoRequested,
              onRefresh: _fetchVideosIfNeeded,
              onLoadMore: _loadMoreVideos,
              scrollStorageKey: 'search-detail-video-${widget.keyword}',
            ),
          ),
          RepaintBoundary(
            child: _SearchPostTabBody(
              provider: searchPostListProvider(_postParams),
              isRequested: _postRequested,
              onRefresh: _fetchPostsIfNeeded,
              onLoadMore: _loadMorePosts,
              showSeparators: false,
              scrollStorageKey: 'search-detail-post-${widget.keyword}',
            ),
          ),
          RepaintBoundary(
            child: _SearchUserTabBody(
              provider: searchUserListProvider(widget.keyword),
              isRequested: _userRequested,
              onRefresh: _fetchUsersIfNeeded,
              onLoadMore: _loadMoreUsers,
              scrollStorageKey: 'search-detail-user-${widget.keyword}',
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchVideoTabBody extends ConsumerStatefulWidget {
  const _SearchVideoTabBody({
    required this.provider,
    required this.isRequested,
    required this.onRefresh,
    required this.onLoadMore,
    required this.scrollStorageKey,
  });

  final dynamic provider;
  final bool isRequested;
  final VoidCallback onRefresh;
  final VoidCallback onLoadMore;
  final String scrollStorageKey;

  @override
  ConsumerState<_SearchVideoTabBody> createState() =>
      _SearchVideoTabBodyState();
}

class _SearchVideoTabBodyState extends ConsumerState<_SearchVideoTabBody>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final loading = ref.watch(
      widget.provider.select((state) => state.loading as bool),
    );
    final finished = ref.watch(
      widget.provider.select((state) => state.finished as bool),
    );
    final results = ref.watch(
      widget.provider.select((state) => state.list as List<dynamic>),
    );

    return GeneralVideoTab(
      finished: finished,
      onRefresh: widget.onRefresh,
      onLoadMore: widget.onLoadMore,
      isLoaded: widget.isRequested,
      loading: loading,
      results: results.cast<VideoInfo>(),
      provider: widget.provider,
      scrollStorageKey: widget.scrollStorageKey,
    );
  }
}

class _SearchPostTabBody extends ConsumerStatefulWidget {
  const _SearchPostTabBody({
    required this.provider,
    required this.isRequested,
    required this.onRefresh,
    required this.onLoadMore,
    required this.showSeparators,
    required this.scrollStorageKey,
  });

  final dynamic provider;
  final bool isRequested;
  final VoidCallback onRefresh;
  final VoidCallback onLoadMore;
  final bool showSeparators;
  final String scrollStorageKey;

  @override
  ConsumerState<_SearchPostTabBody> createState() => _SearchPostTabBodyState();
}

class _SearchPostTabBodyState extends ConsumerState<_SearchPostTabBody>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final loading = ref.watch(
      widget.provider.select((state) => state.loading as bool),
    );
    final finished = ref.watch(
      widget.provider.select((state) => state.finished as bool),
    );
    final results = ref.watch(
      widget.provider.select((state) => state.list as List<dynamic>),
    );

    return GeneralPostTab(
      finished: finished,
      onRefresh: widget.onRefresh,
      onLoadMore: widget.onLoadMore,
      isLoaded: widget.isRequested,
      loading: loading,
      results: results.cast<ForumPost>(),
      scrollStorageKey: widget.scrollStorageKey,
      showSeparators: widget.showSeparators,
    );
  }
}

class _SearchUserTabBody extends ConsumerStatefulWidget {
  const _SearchUserTabBody({
    required this.provider,
    required this.isRequested,
    required this.onRefresh,
    required this.onLoadMore,
    required this.scrollStorageKey,
  });

  final dynamic provider;
  final bool isRequested;
  final VoidCallback onRefresh;
  final VoidCallback onLoadMore;
  final String scrollStorageKey;

  @override
  ConsumerState<_SearchUserTabBody> createState() => _SearchUserTabBodyState();
}

class _SearchUserTabBodyState extends ConsumerState<_SearchUserTabBody>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final loading = ref.watch(
      widget.provider.select((state) => state.loading as bool),
    );
    final finished = ref.watch(
      widget.provider.select((state) => state.finished as bool),
    );
    final results = ref.watch(
      widget.provider.select((state) => state.list as List<dynamic>),
    );

    return GeneralUserTab(
      finished: finished,
      onRefresh: widget.onRefresh,
      onLoadMore: widget.onLoadMore,
      isLoaded: widget.isRequested,
      loading: loading,
      results: results.cast<UserInfo>(),
      scrollStorageKey: widget.scrollStorageKey,
    );
  }
}
