import 'package:live_app/api/campaign_api.dart';
import 'package:live_app/api/services/base_service.dart';
import 'package:live_app/models/api_response.dart';
import 'package:live_app/models/campaign.dart';
import 'package:live_app/models/user_progress.dart';

class CampaignService extends BaseService {
  CampaignService(super.client);

  Future<ApiResponse<Campaign>> getCampaign() {
    return post<Campaign>(
      CampaignApi.getCampaign,
      fromJson: (json) => Campaign.fromJson(json),
    );
  }

   Future<ApiResponse<UserProgress>> getUserProgress({required int campaignId}) {
    return post<UserProgress>(
      CampaignApi.userProgress,
      body: {'campaign_id': campaignId},
      fromJson: (json) => UserProgress.fromJson(json),
    );
  }
}