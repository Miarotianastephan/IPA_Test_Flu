import 'package:dio/dio.dart';
import '../../config/storage_config.dart';

class LanguageInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final savedLang = await StorageService.instance.getValue<String>('lang');
    final lang = savedLang ?? 'en';
    options.headers['x-app-language'] = lang;
    super.onRequest(options, handler);
  }
}
