import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/category_tag.dart';
import 'package:live_app/provider/notifier/base_list_notifier.dart';

import '../models/base_list_state.dart';
import '../models/page_response.dart';
import 'api_provider.dart';

class ForumCategoryTagListNotifier extends BaseListNotifier<CategoryTag> {
  final String? categoryId;

  ForumCategoryTagListNotifier(super.ref, {this.categoryId});

  @override
  Future<PageResponse<CategoryTag>?> loadList({
    required int page,
    int? limit,
  }) async {
    final service = ref.read(forumServiceProvider);
    final res = await service.forumCategoryTag(categoryId: categoryId);
    return res.data;
  }
}

final forumCategoryTagProvider = StateNotifierProvider.family<
    ForumCategoryTagListNotifier,
    BaseListState<CategoryTag>,
    String?>(
  (ref, categoryId) =>
      ForumCategoryTagListNotifier(ref, categoryId: categoryId),
);
