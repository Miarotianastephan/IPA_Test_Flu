import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/page_params.dart';
import 'package:live_app/models/page_response.dart';
import 'package:live_app/models/video_info.dart';

import '../models/video_list_state.dart';
import 'api_provider.dart';
import 'notifier/video_list_notifier.dart';

enum UserVideoListType { favorite, history, like }

/// 通用用户视频列表 Notifier
class UserVideoListNotifier extends BaseVideoListNotifier {
  final UserVideoListType listType;

  UserVideoListNotifier(
    super.ref, {
    required this.listType,
  });

  @override
  Future<PageResponse<VideoInfo>?> loadList({required int page}) async {
    final service = ref.read(videoServiceProvider);
    final params = PageParams(page: page);

    switch (listType) {
      case UserVideoListType.favorite:
        return (await service.favoriteList(params)).data;
      case UserVideoListType.history:
        return (await service.historyList(params)).data;
      case UserVideoListType.like:
        return (await service.likeList(params)).data;
    }
  }
}

/// Provider family: keyed by listType only
final userVideoListProvider =
    StateNotifierProvider.family<
      UserVideoListNotifier,
      VideoListState,
      UserVideoListType
    >(
      (ref, listType) =>
          UserVideoListNotifier(ref, listType: listType),
    );
