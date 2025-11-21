import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/my_post_providers.dart';
import '../../provider/my_video_providers.dart';
import '../../widgets/general_post_tab.dart';
import '../../widgets/general_video_tab.dart';
import '../../widgets/video_type_toggle_button.dart';

class LikePage extends ConsumerStatefulWidget {
  const LikePage({super.key});

  @override
  ConsumerState<LikePage> createState() => _LikePageState();
}

class _LikePageState extends ConsumerState<LikePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _isLongVideo = false;
  bool _videoLoaded = false;
  bool _postLoaded = false;

  int get _videoType => _isLongVideo ? 2 : 1;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;

      setState(() {});

      if (_tabController.index == 1) {
        _fetchPosts();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 350));
      _fetchVideos();
    });
  }

  bool get _isVideoTab => _tabController.index == 0;

  void _fetchVideos() {
    ref
        .read(
          userVideoListProvider((
            type: _videoType,
            listType: UserVideoListType.like,
          )).notifier,
        )
        .fetch(refresh: true);
  }

  void _loadMoreVideos() {
    final provider = userVideoListProvider((
      type: _videoType,
      listType: UserVideoListType.like,
    ));

    final notifier = ref.read(provider.notifier);
    final state = ref.read(provider);

    if (state.loading || state.finished) return;

    notifier.fetch(refresh: false);
  }

  void _fetchPosts() {
    ref
        .read(userPostListProvider(UserPostListType.liked).notifier)
        .fetch(refresh: true);
  }

  void _loadMorePosts() {
    final provider = userPostListProvider(UserPostListType.liked);
    final notifier = ref.read(provider.notifier);
    final state = ref.read(provider);

    if (state.loading || state.finished) return;

    notifier.fetch(refresh: false);
  }

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

    final videoProvider = userVideoListProvider((
      type: _videoType,
      listType: UserVideoListType.like,
    ));

    final postProvider = userPostListProvider(UserPostListType.liked);

    ref.listen(videoProvider, (prev, next) {
      if (prev?.loading == true && next.loading == false) {
        setState(() => _videoLoaded = true);
      }
    });

    ref.listen(postProvider, (prev, next) {
      if (next.loading == false) {
        setState(() => _postLoaded = true);
      }
    });

    final videoState = ref.watch(videoProvider);
    final postState = ref.watch(postProvider);

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
            child: const Text("我的点赞", style: TextStyle(color: Colors.white)),
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
            provider: videoProvider,
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
        ],
      ),
    );
  }
}
