import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/page_params.dart';
import '../models/page_response.dart';
import '../models/video_info.dart';
import '../models/video_list_state.dart';
import 'notifier/video_list_notifier.dart';
import 'api_provider.dart';

class HomeVideoListNotifier extends BaseVideoListNotifier {
  final int type;
  final int featuredType;

  HomeVideoListNotifier(super.ref, this.type, this.featuredType);

  @override
  Future<PageResponse<VideoInfo>?> loadList({required int page}) async {
    final videoService = ref.read(videoServiceProvider);
    final res = await videoService.homeList(
      PageParams(page: page),
      type,
      featuredType,
    );
    return res.data;
  }
}

final homeVideoListProvider =
StateNotifierProvider.family<
      HomeVideoListNotifier,
      VideoListState,
      (int type, int featuredType)
    >((ref, tuple) => HomeVideoListNotifier(ref, tuple.$1, tuple.$2));