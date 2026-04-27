import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/category_tag.dart';
import 'package:live_app/models/video_tag.dart';
import 'package:live_app/provider/notifier/base_list_notifier.dart';

import '../models/base_list_state.dart';
import '../models/page_params.dart';
import '../models/page_response.dart';
import '../models/video_category.dart';
import 'api_provider.dart';

/// 分类列表（支持 onlyHome 和分页）
class VideoCategoryListNotifier extends BaseListNotifier<VideoCategory> {
  final bool onlyHome;

  VideoCategoryListNotifier(super.ref, {required this.onlyHome});

  @override
  Future<PageResponse<VideoCategory>?> loadList({
    required int page,
    int? limit,
  }) async {
    final service = ref.read(videoServiceProvider);
    final res = await service.categoryList(
      PageParams(page: page, limit: limit ?? 20),
      onlyHome: onlyHome,
    );
    return res.data;
  }
}

class VideoTagListNotifier extends BaseListNotifier<VideoTag> {
  VideoTagListNotifier(super.ref);

  @override
  Future<PageResponse<VideoTag>?> loadList({
    required int page,
    int? limit,
  }) async {
    final service = ref.read(videoServiceProvider);
    final res = await service.tagList(
      PageParams(page: page, limit: limit ?? 20),
    );
    return res.data;
  }
}

class VideoCategoryTagListNotifier extends BaseListNotifier<CategoryTag> {
  final String categoryId;

  VideoCategoryTagListNotifier(super.ref, {required this.categoryId});

  @override
  Future<PageResponse<CategoryTag>?> loadList({
    required int page,
    int? limit,
  }) async {
    debugPrint('Loading category tags for categoryId: $categoryId');
    final service = ref.read(videoServiceProvider);
    final res = await service.videoCategoryTag(categoryId: categoryId);
    debugPrint('videoCategoryTag response: ${res.data}');
    debugPrint('videoCategoryTag list length: ${res.data?.list.length ?? 0}');
    return res.data;
  }
}

/// 参数使用 record：({bool onlyHome})
final videoCategoryListProvider =
    StateNotifierProvider.family<
      VideoCategoryListNotifier,
      BaseListState<VideoCategory>,
      bool
    >((ref, onlyHome) => VideoCategoryListNotifier(ref, onlyHome: onlyHome));

final videoTagListProvider =
    StateNotifierProvider<VideoTagListNotifier, BaseListState<VideoTag>>(
      (ref) => VideoTagListNotifier(ref),
    );

final videoCategoryTagProvider =
    StateNotifierProvider.family<
      VideoCategoryTagListNotifier,
      BaseListState<CategoryTag>,
      String
    >(
      (ref, categoryId) =>
          VideoCategoryTagListNotifier(ref, categoryId: categoryId),
    );

/// Provider pour l'index de la catégorie sélectionnée
final selectedCategoryIdProvider = StateProvider<int>((ref) => 0);

/// Provider pour obtenir la catégorie actuellement sélectionnée
final selectedVideoCategoryProvider = Provider<VideoCategory?>((ref) {
  final id = ref.watch(selectedCategoryIdProvider);
  final state = ref.watch(videoCategoryListProvider(true));
  final categories = state.list;
  if (categories.isEmpty) {
    return null;
  }
  return categories[id];
});
