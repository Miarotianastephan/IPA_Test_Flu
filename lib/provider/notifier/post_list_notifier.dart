import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/base_list_state.dart';
import '../../models/forum_post.dart';
import '../../models/page_response.dart';

/// 通用帖子列表逻辑
abstract class BasePostListNotifier extends StateNotifier<BaseListState<ForumPost>> {
  final Ref ref;

  BasePostListNotifier(this.ref) : super(BaseListState<ForumPost>());

  /// 子类负责实现：加载帖子接口
  Future<PageResponse<ForumPost>?> loadList({
    required int page,
    int limit = 20,
  });

  /// 拉取/加载更多
  Future<void> fetch({bool refresh = false, int limit = 20}) async {
    if (state.loading || (state.finished && !refresh)) return;

    try {
      state = state.copyWith(loading: true);

      final page = refresh ? 1 : state.page;
      final response = await loadList(page: page, limit: limit);

      final newList = response?.list ?? <ForumPost>[];
      final total = response?.total ?? 0;

      final merged = refresh ? newList : [...state.list, ...newList];

      state = state.copyWith(
        list: merged,
        page: page + 1,
        loading: false,
        finished: newList.isEmpty,
        total: total,
      );
    } catch (e, st) {
      debugPrint('Post fetch error: $e\n$st');
      state = state.copyWith(loading: false);
    }
  }
}
