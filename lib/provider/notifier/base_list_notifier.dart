import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/base_list_state.dart';
import '../../models/page_response.dart';


abstract class BaseListNotifier<T> extends StateNotifier<BaseListState<T>> {
  final Ref ref;

  BaseListNotifier(this.ref) : super(BaseListState<T>());

  Future<PageResponse<T>?> loadList({required int page, int? limit});

  Future<void> fetch({bool refresh = false, int limit = 20}) async {
    if (state.loading || (state.finished && !refresh)) return;

    try {
      state = state.copyWith(loading: true);

      final page = refresh ? 1 : state.page;
      final pageResponse = await loadList(page: page, limit: limit);

      final List<T> newList = pageResponse?.list ?? List<T>.empty(growable: true);
      final total = pageResponse?.total ?? 0;
      final merged = refresh ? newList : [...state.list, ...newList];

      state = state.copyWith(
        list: merged,
        page: page + 1,
        loading: false,
        total: total,
        finished: newList.isEmpty,
      );
    } catch (e, st) {
      debugPrint('fetch error: $e\n$st');
      state = state.copyWith(loading: false);
    }
  }
}