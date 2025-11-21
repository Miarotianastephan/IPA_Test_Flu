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
  }) async {
    final data = await client.post(endpoint, data: body);
    
    // http code 已经在 Dio 层会抛 DioError，这里只需要业务逻辑判断
    final response = ApiResponse<T>.fromJson(
      data,
      fromJson ?? (json) => json as T,
    );

    if (response.code != 1) {
      ToastUtil.error(response.msg);

      // 抛出异常，调用方可以 catch
      throw Exception(response.msg);
    } 

    return response;
  }
}
