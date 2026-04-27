import 'dart:convert';
import 'dart:io' as io;

import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:live_app/config/i18n_cache_manager.dart';
import 'package:live_app/utils/app_lang_version_utils.dart';
import 'package:live_app/utils/decrypt_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'interceptors/auth_interceptor.dart';
import 'interceptors/network_error_interceptor.dart';

class ApiClient {
  static ApiClient? _instance;
  final Dio _dio;
  String _baseUrl;

  final noRetryStatusCodes = {
    400,
    401,
    403,
    404,
    409,
    422,
    429,
    500,
    502,
    503,
    504,
    522,
  };

  static String _getValidBaseUrl(String? baseUrl) {
    if (baseUrl != null && baseUrl.isNotEmpty && _isValidUrl(baseUrl)) {
      return baseUrl;
    }

    final envUrl = dotenv.env['API_BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty && _isValidUrl(envUrl)) {
      return envUrl;
    }
    return 'https://back.99sq20.fun';
  }

  static bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  ApiClient._internal({BaseOptions? options, String? baseUrl})
    : _baseUrl = _getValidBaseUrl(baseUrl),
      _dio = Dio(
        options ??
            BaseOptions(
              baseUrl: _getValidBaseUrl(baseUrl),
              connectTimeout: const Duration(seconds: 60),
              receiveTimeout: const Duration(seconds: 60),
            ),
      ) {
    _dio.interceptors.addAll([
      NetworkErrorInterceptor(_dio),
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
        filter: (options, args) {
          if (options.method == 'GET') {
            return args.isResponse == false;
          }
          return true;
        },
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
          // 网络错误：不重试
          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.connectionError) {
            return false;
          }

          // HTTP 错误：白名单方式
          final status = error.response?.statusCode;
          if (status != null && noRetryStatusCodes.contains(status)) {
            return false;
          }

          // 其他情况才重试
          return true;
        },
      ),
    ]);
  }

  factory ApiClient({BaseOptions? options, String? baseUrl}) {
    if (_instance == null || baseUrl != null) {
      _instance = ApiClient._internal(options: options, baseUrl: baseUrl);
    }
    return _instance!;
  }

  static ApiClient get instance {
    _instance ??= ApiClient._internal();
    return _instance!;
  }

  Dio get dio => _dio;

  String get baseUrl => _baseUrl;

  /// 动态修改 baseUrl
  void setBaseUrl(String url) {
    _baseUrl = url;
    _dio.options.baseUrl = url;
  }

  Future<Map<String, String>> _getLangHeader() async {
    final cacheManager = I18nCacheManager();
    final selectedLang = await cacheManager.loadSelectedLanguage();
    String lang = selectedLang?['language'] ?? AppLangVersionUtils.getLanguageCode();
    debugPrint('x-app-language: $lang');
    return {'x-app-language': lang};
  }

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? params,
    String? baseUrl,
  }) async {
    final fullUrl = (baseUrl ?? _baseUrl) + path;
    final langHeader = await _getLangHeader();
    final response = await _dio.get(
      fullUrl,
      queryParameters: params,
      options: Options(headers: langHeader),
    );
    return await _processResponse<T>(response);
  }

  Future<T> _processResponse<T>(Response response) async {
    try {
      final rawData = response.data;

      if (rawData == null) {
        return null as T;
      }

      if (rawData is Map || rawData is List) {
        return rawData as T;
      }

      if (rawData is String) {
        final data = rawData.trim();
        if (_isEncryptedResponse(data)) {
          final decrypted = await DecryptUtils(
            dotenv.env['ENCRYPTION_KEY'] ?? "",
          ).decryptJsonAsync(data);
          return (decrypted is String ? jsonDecode(decrypted) : decrypted) as T;
        }
        try {
          return jsonDecode(data) as T;
        } catch (_) {
          return data as T;
        }
      }

      return rawData as T;
    } catch (e) {
      debugPrint('[ApiClient] Error processing response: $e');
      return response.data as T;
    }
  }

  bool _isEncryptedResponse(String responseData) {
    try {
      if (responseData.trimLeft().startsWith('{') ||
          responseData.trimLeft().startsWith('[')) {
        return false;
      }
      final base64Pattern = RegExp(r'^[A-Za-z0-9+/=_-]+$');
      if (base64Pattern.hasMatch(responseData.trim()) &&
          responseData.length > 50) {
        return true;
      }
      jsonDecode(responseData);
      return false;
    } catch (e) {
      return true;
    }
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
    final langHeader = await _getLangHeader();

    final response = await _dio.post(
      fullUrl,
      data: payload,
      queryParameters: queryParameters,
      options: Options(headers: langHeader),
    );

    return _processResponse<T>(response);
  }

  Future<String> postRaw(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    String? baseUrl,
  }) async {
    final fullUrl = (baseUrl ?? _baseUrl) + path;
    final langHeader = await _getLangHeader();

    final response = await _dio.post(
      fullUrl,
      data: data,
      queryParameters: queryParameters,
      options: Options(responseType: ResponseType.plain, headers: langHeader),
    );

    return response.data.toString();
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
            extra: {'skipAuth': true},
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
