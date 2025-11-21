import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/search_post_list_provider.dart';
import '../provider/search_user_list_provider.dart';
import '../provider/search_video_list_provider.dart';
import '../widgets/general_post_tab.dart';
import '../widgets/general_user_tab.dart';
import '../widgets/general_video_tab.dart';
import '../widgets/video_type_toggle_button.dart';

class SearchDetailPage extends ConsumerStatefulWidget {
  final String keyword;

  const SearchDetailPage({super.key, required this.keyword});

  @override
  ConsumerState<SearchDetailPage> createState() => _SearchDetailPageState();
}

class _SearchDetailPageState extends ConsumerState<SearchDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _isLongVideo = false;
  bool _videoLoaded = false;
  bool _postLoaded = false;
  bool _userLoaded = false;

  int get _videoType => _isLongVideo ? 2 : 1;

  SearchPostQueryParams get _postParams =>
      SearchPostQueryParams(keyword: widget.keyword);

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);

    // 统一 tab 加载规则
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;

      // rebuild for title alignment / actions visibility
      setState(() {});

      switch (_tabController.index) {
        case 1:
          _fetchPosts();
          break;
        case 2:
          _fetchUser();
          break;
      }
    });

    // 初次加载视频
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 350));
      _fetchVideos();
    });
  }

  bool get _isVideoTab => _tabController.index == 0;

  /// 视频数据加载
  void _fetchVideos() {
    ref
        .read(
          searchVideoListProvider((
            keyword: widget.keyword,
            sort: null,
            type: _videoType,
          )).notifier,
        )
        .fetch(refresh: true);
  }

  void _loadMoreVideos() {
    final notifier = ref.read(
      searchVideoListProvider((
        keyword: widget.keyword,
        sort: null,
        type: _videoType,
      )).notifier,
    );

    final state = ref.read(
      searchVideoListProvider((
        keyword: widget.keyword,
        sort: null,
        type: _videoType,
      )),
    );

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

  /// 切换短/长视频
  void _toggleVideoType() {
    setState(() {
      _isLongVideo = !_isLongVideo;
      _videoLoaded = false;
    });
    _fetchVideos();
  }

  @override
  Widget build(BuildContext context) {
    const background = Colors.black;

    ref.listen(
      searchVideoListProvider((
        keyword: widget.keyword,
        sort: null,
        type: _videoType,
      )),
      (prev, next) {
        if (prev?.loading == true && next.loading == false) {
          setState(() => _videoLoaded = true);
        }
      },
    );

    ref.listen(searchPostListProvider(_postParams), (prev, next) {
      if (next.loading == false) {
        setState(() => _postLoaded = true);
      }
    });

    ref.listen(searchUserListProvider(widget.keyword), (prev, next) {
      if (next.loading == false) {
        setState(() => _userLoaded = true);
      }
    });

    final videoState = ref.watch(
      searchVideoListProvider((
        keyword: widget.keyword,
        sort: null,
        type: _videoType,
      )),
    );

    final postState = ref.watch(searchPostListProvider(_postParams));

    final userState = ref.watch(searchUserListProvider(widget.keyword));

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: AnimatedPadding(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
          padding: EdgeInsets.only(right: _isVideoTab ? 0 : 56),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOut,
            alignment: _isVideoTab ? Alignment.centerLeft : Alignment.center,
            child: Text(
              "\"${widget.keyword}\"",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
        centerTitle: !_isVideoTab,
        actions: [
          if (_isVideoTab)
            VideoTypeToggleButton(
              isLongVideo: _isLongVideo,
              onToggle: _toggleVideoType,
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: "视频"),
            Tab(text: "帖子"),
            Tab(text: "用户"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          /// 视频 tab
          GeneralVideoTab(
            finished: videoState.finished,
            onRefresh: _fetchVideos,
            onLoadMore: _loadMoreVideos,
            isLoaded: _videoLoaded,
            loading: videoState.loading,
            results: videoState.list,
            isLongVideo: _isLongVideo,
            provider: searchVideoListProvider((
              keyword: widget.keyword,
              sort: null,
              type: _videoType,
            )),
          ),

          /// 帖子 tab
          GeneralPostTab(
            finished: postState.finished,
            onRefresh: _fetchPosts,
            onLoadMore: _loadMorePosts,
            isLoaded: _postLoaded,
            loading: postState.loading,
            results: postState.list,
          ),

          /// 用户 tab
          GeneralUserTab(
            finished: userState.finished,
            onRefresh: _fetchUser,
            onLoadMore: _loadMoreUsers,
            isLoaded: _userLoaded,
            loading: userState.loading,
            results: userState.list,
          ),
        ],
      ),
    );
  }
}
