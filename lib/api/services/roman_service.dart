import 'package:live_app/models/roman_response.dart';

import '../../models/api_response.dart';

import '../roman_api.dart';
import 'base_service.dart';

class RomanService extends BaseService {
  RomanService(super.client);

  Future<ApiResponse<RomanResponse>> romans() {
    return post<RomanResponse>(
      RomanApi.roman,
      body: {},
      fromJson: (json) => RomanResponse.fromJson(json as Map<String, dynamic>),
    );
  }
}
