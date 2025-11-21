import '../../models/api_response.dart';
import '../app_api.dart';
import './base_service.dart';

class AppService extends BaseService {
  AppService(super.client);

  Future<ApiResponse<Map<String, dynamic>>> appConfig() {
    return post<Map<String, dynamic>>(AppApi.appConfig);
  }
}