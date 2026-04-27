import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/base_list_state.dart';
import '../models/page_response.dart';
import '../models/userinfo.dart';
import 'api_provider.dart';
import 'notifier/base_list_notifier.dart';

class SponsoredUsersNotifier extends BaseListNotifier<UserInfo> {
  SponsoredUsersNotifier(super.ref);

  @override
  Future<PageResponse<UserInfo>?> loadList({
    required int page,
    int? limit,
  }) async {
    final userService = ref.read(userServiceProvider);
    final response = await userService.getSponsoredUser(
      page: page,
      limit: limit ?? 20,
    );
    return response.data;
  }
}

final sponsoredUsersProvider =
    StateNotifierProvider<SponsoredUsersNotifier, BaseListState<UserInfo>>((
      ref,
    ) {
      return SponsoredUsersNotifier(ref);
    });
