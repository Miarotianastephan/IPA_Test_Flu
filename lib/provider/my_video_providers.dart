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
  final int type;
  final UserVideoListType listType;

  UserVideoListNotifier(
    super.ref, {
    required this.type,
    required this.listType,
  });

  @override
  Future<PageResponse<VideoInfo>?> loadList({required int page}) async {
    final service = ref.read(videoServiceProvider);
    final params = PageParams(page: page);

    switch (listType) {
      case UserVideoListType.favorite:
        return (await service.favoriteList(params, type)).data;
      case UserVideoListType.history:
        return (await service.historyList(params, type)).data;
      case UserVideoListType.like:
        return (await service.likeList(params, type)).data;
    }
  }
}

/// Provider family: 支持 type + listType
final userVideoListProvider =
    StateNotifierProvider.family<
      UserVideoListNotifier,
      VideoListState,
      ({int type, UserVideoListType listType})
    >(
      (ref, args) =>
          UserVideoListNotifier(ref, type: args.type, listType: args.listType),
    );
