import 'base_list_state.dart';
import 'video_info.dart';

class VideoListState extends BaseListState<VideoInfo> {
  final Map<int, List<int>> userVideoIndexMap;
  final Map<int, int> videoIndexMap;

  VideoListState({
    List<VideoInfo>? list,
    super.page,
    super.total,
    super.loading,
    super.finished,
    Map<int, List<int>>? userVideoIndexMap,
    Map<int, int>? videoIndexMap,
  }) : userVideoIndexMap = userVideoIndexMap ?? <int, List<int>>{},
        videoIndexMap = videoIndexMap ?? <int, int>{},
        super(
        list: list ?? <VideoInfo>[],
      );


  @override
  VideoListState copyWith({
    List<VideoInfo>? list,
    int? page,
    int? total,
    bool? loading,
    bool? finished,
    Map<int, List<int>>? userVideoIndexMap,
    Map<int, int>? videoIndexMap,
  }) {
    return VideoListState(
      list: list ?? this.list,
      page: page ?? this.page,
      total: total ?? this.total,
      loading: loading ?? this.loading,
      finished: finished ?? this.finished,
      userVideoIndexMap: userVideoIndexMap ?? this.userVideoIndexMap,
      videoIndexMap: videoIndexMap ?? this.videoIndexMap,
    );
  }

  /// 从当前视频列表快速生成索引表
  Map<int, List<int>> buildUserIndexMap() {
    final map = <int, List<int>>{};
    for (int i = 0; i < list.length; i++) {
      final userId = list[i].userId;
      map.putIfAbsent(userId, () => []).add(i);
    }
    return map;
  }

  /// 从当前视频列表快速生成视频ID索引映射表
  Map<int, int> buildVideoIndexMap() {
    final map = <int, int>{};
    for (int i = 0; i < list.length; i++) {
      final videoId = list[i].id;
      map[videoId] = i;
    }
    return map;
  }
}