import 'package:live_app/api/banner_api.dart';
import 'package:live_app/api/services/base_service.dart';
import 'package:live_app/models/api_response.dart';
import 'package:live_app/models/banner.dart';
import 'package:live_app/models/page_response.dart';

class BannerService extends BaseService {
  BannerService(super.client);

  Future<ApiResponse<PageResponse<BannerModel>>> getBanner({
    required int page,
    required int limit,
  }) {
    return post<PageResponse<BannerModel>>(
      BannerApi.banner,
      body: {"page": page, "limit": limit},
      fromJson: (json) =>
          PageResponse.fromJson(json, (item) => BannerModel.fromJson(item)),
    );
  }
}
