import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/api/services/user_service.dart';
import 'package:live_app/models/page_response.dart';
import 'package:live_app/models/video_info.dart';
import 'package:live_app/models/video_list_state.dart';
import 'package:live_app/provider/api_provider.dart';
import 'package:live_app/provider/notifier/video_list_notifier.dart';

class PurchasedVideoNotifier extends BaseVideoListNotifier {
  final UserService _userService;

  PurchasedVideoNotifier(Ref ref, this._userService) : super(ref) {}

  @override
  Future<PageResponse<VideoInfo>?> loadList({required int page}) async {
    final response = await _userService.findContentBought(
      type: 'video',
      page: page,
      limit: 20,
    );

    if (response.data == null) {
      return null;
    }

    final contentBoughtList = response.data!.list;
    final videos = contentBoughtList
        .map((e) => e.video)
        .whereType<VideoInfo>()
        .toList();

    return PageResponse(
      list: videos,
      total: response.data!.total,
      limit: response.data!.limit,
      page: response.data!.page,
    );
  }
}

final purchasedVideoProvider =
    StateNotifierProvider<PurchasedVideoNotifier, VideoListState>((ref) {
      final userService = ref.watch(userServiceProvider);
      return PurchasedVideoNotifier(ref, userService);
    });
