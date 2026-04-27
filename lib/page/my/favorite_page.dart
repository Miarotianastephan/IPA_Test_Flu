import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/i18n_provider.dart';

import '../../provider/my_post_providers.dart';
import '../../provider/my_video_providers.dart';
import '../../widgets/general_post_tab.dart';
import '../../widgets/general_video_tab.dart';

class FavoritePage extends ConsumerStatefulWidget {
  const FavoritePage({super.key});

  @override
  ConsumerState<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends ConsumerState<FavoritePage>
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

      if (_tabController.index == 1) {
        _fetchPosts();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 350));
      _fetchVideos();
    });
  }

  void _fetchVideos() {
    final provider = userVideoListProvider(UserVideoListType.favorite);

    ref.invalidate(provider);
    ref.read(provider.notifier).fetch(refresh: true);
  }

  void _loadMoreVideos() {
    final provider = userVideoListProvider(UserVideoListType.favorite);

    final notifier = ref.read(provider.notifier);
    final state = ref.read(provider);

    if (state.loading || state.finished) return;

    notifier.fetch(refresh: false);
  }

  void _fetchPosts() {
    ref
        .read(userPostListProvider(UserPostListType.favorite).notifier)
        .fetch(refresh: true);
  }

  void _loadMorePosts() {
    final provider = userPostListProvider(UserPostListType.favorite);
    final notifier = ref.read(provider.notifier);
    final state = ref.read(provider);

    if (state.loading || state.finished) return;

    notifier.fetch(refresh: false);
  }

  @override
  Widget build(BuildContext context) {
    const background = Colors.black;
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);
    final videoProvider = userVideoListProvider(UserVideoListType.favorite);

    final postProvider = userPostListProvider(UserPostListType.favorite);

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
        title: Text(
          translate("favorites"),
          style: TextStyle(color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: [
            Tab(text: translate("video")),
            Tab(text: translate("post")),
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
