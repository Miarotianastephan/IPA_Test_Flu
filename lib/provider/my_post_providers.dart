import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/base_list_state.dart';
import '../models/forum_post.dart';
import '../models/page_params.dart';
import '../models/page_response.dart';
import 'api_provider.dart';
import 'notifier/post_list_notifier.dart';

enum UserPostListType {
  favorite, // 我的收藏
  history, // 我的历史
  liked, // 我的点赞
}

class UserPostListNotifier extends BasePostListNotifier {
  final UserPostListType type;

  UserPostListNotifier(super.ref, {required this.type});

  @override
  Future<PageResponse<ForumPost>?> loadList({
    required int page,
    int limit = 20,
  }) async {
    final service = ref.read(forumServiceProvider);
    final params = PageParams(page: page, limit: limit);

    switch (type) {
      case UserPostListType.favorite:
        return (await service.myFavorites(params)).data;

      case UserPostListType.history:
        return (await service.myHistory(params)).data;

      case UserPostListType.liked:
        return (await service.myLiked(params)).data;
    }
  }
}

final userPostListProvider =
    StateNotifierProvider.family<
      UserPostListNotifier,
      BaseListState<ForumPost>,
      UserPostListType
    >((ref, type) {
      return UserPostListNotifier(ref, type: type);
    });
