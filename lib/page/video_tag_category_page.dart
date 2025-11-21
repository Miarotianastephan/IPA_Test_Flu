import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/widgets/video_type_toggle_button.dart';

import '../provider/search_videos_provider.dart';
import '../widgets/general_video_tab.dart';

/// 区分是“标签页”还是“分类页”
enum VideoTagCategoryType { tag, category }

class VideoTagCategoryPage extends ConsumerStatefulWidget {
  /// 页面标题
  final String title;

  /// type 确定是 tag 还是 分类
  final VideoTagCategoryType type;

  /// tagId 或 categoryId
  final int id;

  const VideoTagCategoryPage({
    super.key,
    required this.title,
    required this.type,
    required this.id,
  });

  @override
  ConsumerState<VideoTagCategoryPage> createState() =>
      _VideoTagCategoryPageState();
}

class _VideoTagCategoryPageState extends ConsumerState<VideoTagCategoryPage> {
  bool _isLongVideo = false;
  bool _videoLoaded = false;

  /// 短视频 1 / 长视频 2
  int get _videoType => _isLongVideo ? 2 : 1;

  /// 根据外部的 type / id 组合成 SearchVideoParams
  SearchVideoParams get _params => SearchVideoParams(
    typeId: _videoType,
    sort: null,
    keyword: null,
    categoryId: widget.type == VideoTagCategoryType.category ? widget.id : null,
    tagId: widget.type == VideoTagCategoryType.tag ? widget.id : null,
    province: null,
    city: null,
  );

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 350));
      _fetchVideos();
    });
  }

  void _fetchVideos() {
    ref.read(searchVideosProvider(_params).notifier).fetch(refresh: true);
  }

  void _loadMoreVideos() {
    final notifier = ref.read(searchVideosProvider(_params).notifier);
    final state = ref.read(searchVideosProvider(_params));

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

    ref.listen(searchVideosProvider(_params), (prev, next) {
      if (prev?.loading == true && next.loading == false) {
        setState(() => _videoLoaded = true);
      }
    });

    final videoState = ref.watch(searchVideosProvider(_params));

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: background,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          VideoTypeToggleButton(
            isLongVideo: _isLongVideo,
            onToggle: _toggleVideoType,
          ),
        ],
      ),
      body: GeneralVideoTab(
        finished: videoState.finished,
        onRefresh: _fetchVideos,
        onLoadMore: _loadMoreVideos,
        isLoaded: _videoLoaded,
        loading: videoState.loading,
        results: videoState.list,
        isLongVideo: _isLongVideo,
        provider: searchVideosProvider(_params),
      ),
    );
  }
}
