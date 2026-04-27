import 'package:dio/dio.dart';
import 'package:live_app/api/services/network_error_service.dart';

class NetworkErrorInterceptor extends Interceptor {
  final Dio dio;

  NetworkErrorInterceptor(this.dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.sendTimeout ||
        (err.type == DioExceptionType.badResponse &&
            (err.response?.statusCode ?? 0) >= 500)) {
      bool userClickedRetry = false;
      await NetworkErrorService().handleError(err, () {
        userClickedRetry = true;
      });

      if (userClickedRetry) {
        try {
          final response = await dio.request(
            err.requestOptions.path,
            data: err.requestOptions.data,
            queryParameters: err.requestOptions.queryParameters,
            options: Options(
              method: err.requestOptions.method,
              headers: err.requestOptions.headers,
              contentType: err.requestOptions.contentType,
              responseType: err.requestOptions.responseType,
            ),
          );
          return handler.resolve(response);
        } on DioException catch (e) {
          return handler.next(e);
        }
      }
    }

    super.onError(err, handler);
  }
}
