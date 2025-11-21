import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/video_list_state.dart';

import '../models/page_params.dart';
import '../models/page_response.dart';
import '../models/search_video_request.dart';
import '../models/video_info.dart';
import 'api_provider.dart';
import 'notifier/video_list_notifier.dart';

class SearchVideoParams {
  final int? typeId;
  final String? sort;
  final String? keyword;
  final int? categoryId;
  final int? tagId;
  final String? province;
  final String? city;

  const SearchVideoParams({
    this.typeId,
    this.sort,
    this.keyword,
    this.categoryId,
    this.tagId,
    this.province,
    this.city,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SearchVideoParams &&
        other.typeId == typeId &&
        other.sort == sort &&
        other.keyword == keyword &&
        other.categoryId == categoryId &&
        other.tagId == tagId &&
        other.province == province &&
        other.city == city;
  }

  @override
  int get hashCode => Object.hash(
    typeId,
    sort,
    keyword,
    categoryId,
    tagId,
    province,
    city,
  );
}

class SearchVideoListNotifier extends BaseVideoListNotifier {
  final SearchVideoParams params;

  SearchVideoListNotifier(super.ref, this.params);

  @override
  Future<PageResponse<VideoInfo>?> loadList({required int page}) async {
    final videoService = ref.read(videoServiceProvider);
    final req = SearchVideoRequest(
      page: PageParams(page: page, limit: 20),
      type: params.typeId,
      sort: params.sort,
      keyword: params.keyword,
      categoryId: params.categoryId,
      tagId: params.tagId,
      province: params.province,
      city: params.city,
    );
    final res = await videoService.searchVideos(req);
    return res.data;
  }
}

final searchVideosProvider =
    StateNotifierProvider.family<
      SearchVideoListNotifier,
      VideoListState,
      SearchVideoParams
    >((ref, params) => SearchVideoListNotifier(ref, params));
