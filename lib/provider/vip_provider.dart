import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/vip.dart';

import 'api_provider.dart';

/// ===============================
/// STATE
/// ===============================
class VipState {
  final List<Vip> vips;
  final bool loading;
  final String? error;

  VipState({this.vips = const [], this.loading = false, this.error});

  VipState copyWith({List<Vip>? vips, bool? loading, String? error}) {
    return VipState(
      vips: vips ?? this.vips,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

/// ===============================
/// NOTIFIER
/// ===============================
class VipNotifier extends StateNotifier<VipState> {
  final Ref ref;

  VipNotifier(this.ref) : super(VipState());

  /// =========================================
  /// LOAD VIPS
  /// =========================================
  Future<void> loadVips() async {
    state = state.copyWith(loading: true, error: null);

    try {
      final service = ref.read(vipServiceProvider);
      final response = await service.list();

      state = state.copyWith(vips: response.data, loading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }
}

/// ===============================
/// PROVIDER
/// ===============================
final vipProvider = StateNotifierProvider<VipNotifier, VipState>((ref) {
  return VipNotifier(ref);
});
