import 'dart:convert';
import 'dart:io' as io;

import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'interceptors/auth_interceptor.dart';
import 'package:path_provider/path_provider.dart';

class ApiClient {
  final Dio _dio;
  String _baseUrl;

  ApiClient({BaseOptions? options})
    : _baseUrl = dotenv.env['API_BASE_URL']!,
      _dio = Dio(
        options ??
            BaseOptions(
              baseUrl: dotenv.env['API_BASE_URL']!,
              connectTimeout: const Duration(seconds: 60),
              receiveTimeout: const Duration(seconds: 60),
            ),
      ) {
    _dio.interceptors.addAll([
      //日志
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
        enabled: kDebugMode,
      ),
      //权限
      AuthInterceptor(),
      //重试
      RetryInterceptor(
        dio: dio,
        logPrint: print,
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
        ],
        retryEvaluator: (error, attempt) {
          // 不重试：明确的网络错误（断网、超时、连接失败）
          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.connectionError) {
            return false;
          }

          // 不重试：业务错误（422）
          if (error.response?.statusCode == 422) {
            return false;
          }

          // 默认：有错误就重试
          return true;
        },
      ),
    ]);
  }

  Dio get dio => _dio;

  /// 动态修改 baseUrl
  void setBaseUrl(String url) {
    _baseUrl = url;
    _dio.options.baseUrl = url;
  }

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? params,
    String? baseUrl,
  }) async {
    final fullUrl = (baseUrl ?? _baseUrl) + path; // 拼接完整 URL
    final response = await _dio.get(fullUrl, queryParameters: params);
    return response.data;
  }

 Future<T> post<T>(
  String path, {
  dynamic data,
  Map<String, dynamic>? queryParameters,
  bool isForm = false,
  String? baseUrl,
}) async {
  final payload = isForm && data != null
      ? FormData.fromMap(data as Map<String, dynamic>)
      : data;

  final fullUrl = (baseUrl ?? _baseUrl) + path;

  final response = await _dio.post(
    fullUrl,
    data: payload,
    queryParameters: queryParameters,
  );

  final result = response.data is String ? jsonDecode(response.data) : response.data;

  return result;
}

}

extension ApiClientDownload on ApiClient {
  /// 下载文件（兼容 Android/iOS/Web）
  /// [save] 是否保存到本地文件（移动端）或缓存（Web 返回 Uint8List）
  /// 返回值：
  /// - save=true && 移动端：File
  /// - save=false 或 Web：Uint8List
  Future<dynamic> downloadFile(
    String url, {
    bool save = true,
    String? savePath,
    void Function(int received, int total)? onProgress,
  }) async {
    try {
      // Web 平台，直接返回 Uint8List
      if (kIsWeb || !save) {
        final response = await _dio.get<List<int>>(
          url,
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: true,
          ),
          onReceiveProgress: onProgress,
        );
        return Uint8List.fromList(response.data!);
      }

      // 移动端且 save = true
      final path =
          savePath ??
          '${(await getTemporaryDirectory()).path}/${DateTime.now().millisecondsSinceEpoch}_${url.split("/").last}';

      await _dio.download(
        url,
        path,
        onReceiveProgress: onProgress,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
        ),
      );

      final file = io.File(path);
      return file;
    } catch (e) {
      throw Exception('下载失败: $e');
    }
  }
}