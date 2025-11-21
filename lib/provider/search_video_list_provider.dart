import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/page_params.dart';
import 'package:live_app/models/page_response.dart';
import 'package:live_app/models/video_info.dart';

import '../../models/search_video_request.dart';
import '../models/video_list_state.dart';
import 'api_provider.dart';
import 'notifier/video_list_notifier.dart';

/// 搜索视频的 Notifier
class SearchVideoListNotifier extends BaseVideoListNotifier {
  final String keyword;
  final String? sort;
  final int? type;

  SearchVideoListNotifier(
    super.ref, {
    required this.keyword,
    this.sort,
    this.type,
  });

  @override
  Future<PageResponse<VideoInfo>?> loadList({required int page}) async {
    final videoService = ref.read(videoServiceProvider);

    final req = SearchVideoRequest(
      page: PageParams(page: page),
      keyword: keyword,
      sort: sort,
      type: type,
    );

    final res = await videoService.searchVideos(req);
    return res.data;
  }
}

/// provider family：支持参数 keyword / sort / type
final searchVideoListProvider =
    StateNotifierProvider.family<
      SearchVideoListNotifier,
      VideoListState,
      ({String keyword, String? sort, int? type})
    >(
      (ref, params) => SearchVideoListNotifier(
        ref,
        keyword: params.keyword,
        sort: params.sort,
        type: params.type,
      ),
    );
