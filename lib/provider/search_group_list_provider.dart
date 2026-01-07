import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/group.dart';

import '../models/base_list_state.dart';
import '../models/page_response.dart';
import 'api_provider.dart';
import 'notifier/base_list_notifier.dart';

/// 用户搜索 Notifier
class SearchGroupListNotifier extends BaseListNotifier<Group> {
  final String keyword;

  SearchGroupListNotifier(super.ref, {required this.keyword});

  @override
  Future<PageResponse<Group>?> loadList({required int page, int? limit}) async {
    final messageService = ref.read(messageServiceProvider);

    final response = await messageService.searchGroups(
      page,
      limit ?? 20,
      keyword,
    );

    return response.data;
  }
}

final searchGroupListProvider =
    StateNotifierProvider.family<
      SearchGroupListNotifier,
      BaseListState<Group>,
      String
    >((ref, keyword) {
      return SearchGroupListNotifier(ref, keyword: keyword);
    });
