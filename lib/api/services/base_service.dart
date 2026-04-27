import '../../models/api_response.dart';
import '../../utils/toast_util.dart';
import '../api_client.dart';

abstract class BaseService {
  final ApiClient client;

  BaseService(this.client);

  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    T Function(dynamic json)? fromJson,
    dynamic body,
    String? baseUrl,
    bool showToast = true,
    bool throwOnError = true,
  }) async {
    final data = await client.post(endpoint, data: body, baseUrl: baseUrl);

    // http code 已经在 Dio 层会抛 DioError，这里只需要业务逻辑判断
    final response = ApiResponse<T>.fromJson(
      data,
      fromJson ?? (json) => json as T,
    );

    if (response.code != 1) {
      if (showToast &&
          response.msg.isNotEmpty &&
          !response.msg.contains('Any conversation found')) {
        // ToastUtil.error(response.msg);
      }

      if (throwOnError) {
        throw Exception(response.msg);
      }
    }

    return response;
  }

  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    T Function(dynamic json)? fromJson,
    String? baseUrl,
    bool showToast = true,
  }) async {
    final data = await client.get(endpoint, baseUrl: baseUrl);

    // http code 已经在 Dio 层会抛 DioError，这里只需要业务逻辑判断
    final response = ApiResponse<T>.fromJson(
      data,
      fromJson ?? (json) => json as T,
    );

    if (response.code != 1) {
      if (showToast &&
          response.msg.isNotEmpty &&
          !response.msg.contains('Any conversation found')) {
        ToastUtil.error(response.msg);
      }

      // 抛出异常，调用方可以 catch
      throw Exception(response.msg);
    }

    return response;
  }
}
