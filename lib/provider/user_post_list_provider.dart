import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/base_list_state.dart';
import '../models/page_params.dart';
import '../models/page_response.dart';
import '../models/forum_post.dart';
import 'notifier/base_list_notifier.dart';
import 'api_provider.dart';

/// 用户帖子列表 Notifier
class UserPostListNotifier extends BaseListNotifier<ForumPost> {
  final int userId;

  UserPostListNotifier(super.ref, this.userId);

  @override
  Future<PageResponse<ForumPost>?> loadList({
    required int page,
    int? limit,
  }) async {
    final forumService = ref.read(forumServiceProvider);

    final res = await forumService.userPosts(
      PageParams(page: page, limit: limit ?? 20),
      userId,
    );

    return res.data;
  }
}

final userPostListProvider =
    StateNotifierProvider.family<
      UserPostListNotifier,
      BaseListState<ForumPost>,
      int
    >((ref, userId) => UserPostListNotifier(ref, userId));
