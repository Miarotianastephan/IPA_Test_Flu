import 'package:live_app/api/ad_video_api.dart';
import 'package:live_app/api/services/base_service.dart';
import 'package:live_app/models/ad_video_config.dart';
import 'package:live_app/models/api_response.dart';
import 'package:live_app/models/page_response.dart';

class AdVideoService extends BaseService {
  AdVideoService(super.client);

  Future<ApiResponse<PageResponse<AdVideoConfig>>> getAdVideoList({
    int page = 1,
    int limit = 20,
  }) {
    return post<PageResponse<AdVideoConfig>>(
      AdVideoApi.list,
      body: {"page": page, "limit": limit},
      fromJson: (json) =>
          PageResponse.fromJson(json, (item) => AdVideoConfig.fromJson(item)),
    );
  }
}