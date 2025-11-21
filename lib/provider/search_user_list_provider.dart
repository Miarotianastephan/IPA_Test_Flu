import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/base_list_state.dart';
import '../models/page_response.dart';
import '../models/userinfo.dart';
import 'api_provider.dart';
import 'notifier/base_list_notifier.dart';

/// 用户搜索 Notifier
class SearchUserListNotifier extends BaseListNotifier<UserInfo> {
  final String keyword;

  SearchUserListNotifier(super.ref, {required this.keyword});

  @override
  Future<PageResponse<UserInfo>?> loadList({
    required int page,
    int? limit,
  }) async {
    final userService = ref.read(userServiceProvider);

    final response = await userService.searchUsers(page, limit ?? 20, keyword);

    return response.data;
  }
}

final searchUserListProvider =
    StateNotifierProvider.family<
      SearchUserListNotifier,
      BaseListState<UserInfo>,
      String
    >((ref, keyword) {
      return SearchUserListNotifier(ref, keyword: keyword);
    });
