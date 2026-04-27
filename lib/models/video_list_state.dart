import 'base_list_state.dart';
import 'video_info.dart';

class VideoListState extends BaseListState<VideoInfo> {
  final Map<String, List<int>> userVideoIndexMap;
  final Map<String, int> videoIndexMap;

  VideoListState({
    List<VideoInfo>? list,
    super.page,
    super.total,
    super.loading,
    super.finished,
    super.offset,
    Map<String, List<int>>? userVideoIndexMap,
    Map<String, int>? videoIndexMap,
  }) : userVideoIndexMap = userVideoIndexMap ?? <String, List<int>>{},
       videoIndexMap = videoIndexMap ?? <String, int>{},
       super(list: list ?? <VideoInfo>[]);

  @override
  VideoListState copyWith({
    List<VideoInfo>? list,
    int? page,
    int? total,
    bool? loading,
    bool? finished,
    int? offset,
    Map<String, List<int>>? userVideoIndexMap,
    Map<String, int>? videoIndexMap,
  }) {
    return VideoListState(
      list: list ?? this.list,
      page: page ?? this.page,
      total: total ?? this.total,
      loading: loading ?? this.loading,
      finished: finished ?? this.finished,
      offset: offset ?? this.offset,
      userVideoIndexMap: userVideoIndexMap ?? this.userVideoIndexMap,
      videoIndexMap: videoIndexMap ?? this.videoIndexMap,
    );
  }

  /// 从当前视频列表快速生成索引表
  Map<String, List<int>> buildUserIndexMap() {
    final map = <String, List<int>>{};
    for (int i = 0; i < list.length; i++) {
      final userId = list[i].userId;
      map.putIfAbsent(userId, () => []).add(i);
    }
    return map;
  }

  /// 从当前视频列表快速生成视频ID索引映射表
  Map<String, int> buildVideoIndexMap() {
    final map = <String, int>{};
    for (int i = 0; i < list.length; i++) {
      final videoId = list[i].id;
      map[videoId] = i;
    }
    return map;
  }
}
