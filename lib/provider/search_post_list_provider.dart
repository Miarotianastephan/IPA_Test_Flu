import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/base_list_state.dart';
import '../models/forum_post.dart';
import '../models/page_params.dart';
import '../models/page_response.dart';
import 'api_provider.dart';
import 'notifier/post_list_notifier.dart';

class SearchPostListNotifier extends BasePostListNotifier {
  final String keyword;
  final String? sort;

  SearchPostListNotifier(
      super.ref, {
        required this.keyword,
        this.sort,
      });

  @override
  Future<PageResponse<ForumPost>?> loadList({
    required int page,
    int limit = 20,
  }) async {
    final forumService = ref.read(forumServiceProvider);

    final response = await forumService.forums(
      pageParams: PageParams(page: page, limit: limit),
      keyword: keyword,
      sort: sort,
    );

    return response.data;
  }
}

final searchPostListProvider =
StateNotifierProvider.family<
    SearchPostListNotifier,
    BaseListState<ForumPost>,
    SearchPostQueryParams
>((ref, params) {
  return SearchPostListNotifier(
    ref,
    keyword: params.keyword,
    sort: params.sort,
  );
});

/// 搜索参数结构体
class SearchPostQueryParams {
  final String keyword;
  final String? sort;

  const SearchPostQueryParams({
    required this.keyword,
    this.sort,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SearchPostQueryParams &&
        other.keyword == keyword &&
        other.sort == sort;
  }

  @override
  int get hashCode => Object.hash(keyword, sort);
}

