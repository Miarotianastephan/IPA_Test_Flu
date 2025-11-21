import 'package:flutter_riverpod/flutter_riverpod.dart';
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
