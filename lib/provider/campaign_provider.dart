import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/api/services/campaign_service.dart';
import 'package:live_app/models/campaign.dart';
import 'package:live_app/provider/api_provider.dart';

class CampaignState {
  final Campaign? campaign;
  final bool isLoading;
  final String? error;

  CampaignState({
    this.campaign,
    this.isLoading = false,
    this.error,
  });

  CampaignState copyWith({
    Campaign? campaign,
    bool? isLoading,
    String? error,
  }) {
    return CampaignState(
      campaign: campaign ?? this.campaign,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CampaignNotifier extends StateNotifier<CampaignState> {
  final CampaignService campaignService;

  CampaignNotifier(this.campaignService) : super(CampaignState());

  Future<void> loadCampaign() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final resp = await campaignService.getCampaign();

      final data = resp.data;
      if (data == null) throw Exception("Response data null");

      state = state.copyWith(
        campaign: data,
        error: null,
      );
    } catch (e) {
      debugPrint("load campaign error: $e");
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void reset() {
    state = CampaignState();
  }
}

final campaignProvider =
    StateNotifierProvider<CampaignNotifier, CampaignState>((ref) {
  final service = ref.watch(campaignServiceProvider);
  return CampaignNotifier(service);
});
