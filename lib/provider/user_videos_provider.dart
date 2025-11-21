import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/page_params.dart';
import '../models/page_response.dart';
import '../models/video_info.dart';
import '../models/video_list_state.dart';
import 'notifier/video_list_notifier.dart';
import 'api_provider.dart';

class UserVideoListNotifier extends BaseVideoListNotifier {
  final int userId;

  UserVideoListNotifier(super.ref, this.userId);

  @override
  Future<PageResponse<VideoInfo>?> loadList({required int page}) async {
    final videoService = ref.read(videoServiceProvider);
    final res = await videoService.userVideos(
      PageParams(page: page, limit: 21),
      userId,
    );
    return res.data;
  }
}

final userVideoListProvider =
StateNotifierProvider.family<UserVideoListNotifier, VideoListState, int>(
      (ref, userId) => UserVideoListNotifier(ref, userId),
    );
