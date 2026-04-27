import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/api/services/ad_service.dart';
import 'package:live_app/constants/ad_placement.dart';
import 'package:live_app/models/ad.dart';
import 'package:live_app/models/base_list_state.dart';
import 'package:live_app/models/page_params.dart';
import 'package:live_app/models/page_response.dart';
import 'package:live_app/provider/api_provider.dart';
import 'package:live_app/provider/notifier/base_list_notifier.dart';

class AdListNotifier extends BaseListNotifier<Ad> {
  final AdService adService;
  final AdPlacement placement;

  AdListNotifier(super.ref, this.adService, this.placement);

  @override
  Future<PageResponse<Ad>?> loadList({required int page, int? limit}) async {
    final res = await adService.getAdList(
      placementCode: placement.code,
      params: PageParams(page: page, limit: limit ?? 5),
    );
    return res.data;
  }

  void reset() {
    state = BaseListState<Ad>();
  }
}

final adListProvider =
    StateNotifierProvider.family<AdListNotifier, BaseListState<Ad>, AdPlacement>((
      ref,
      placement,
    ) {
      final service = ref.watch(adServiceProvider);
      return AdListNotifier(ref, service, placement);
    });
