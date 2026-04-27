import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/services/user_service.dart';
import '../models/base_list_state.dart';
import '../models/forum_post.dart';
import '../models/page_response.dart';
import 'api_provider.dart';
import 'notifier/post_list_notifier.dart';

class PurchasedPostNotifier extends BasePostListNotifier {
  final UserService _userService;

  PurchasedPostNotifier(Ref ref, this._userService) : super(ref);

  @override
  Future<PageResponse<ForumPost>?> loadList({
    required int page,
    int limit = 20,
  }) async {
    final response = await _userService.findContentBought(
      type: 'posts',
      page: page,
      limit: limit,
    );

    if (response.data == null) {
      return null;
    }

    final posts = response.data!.list
        .map((item) => item.post)
        .whereType<ForumPost>()
        .toList();

    return PageResponse(
      list: posts,
      total: response.data!.total,
      limit: response.data!.limit,
      page: response.data!.page,
    );
  }
}

final purchasedPostProvider =
    StateNotifierProvider<PurchasedPostNotifier, BaseListState<ForumPost>>((
      ref,
    ) {
      final userService = ref.watch(userServiceProvider);
      return PurchasedPostNotifier(ref, userService);
    });
