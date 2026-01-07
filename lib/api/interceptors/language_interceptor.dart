import 'package:dio/dio.dart';
import '../../config/i18n_cache_manager.dart';

class LanguageInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final cacheManager = I18nCacheManager();
    final selectedLang = await cacheManager.loadSelectedLanguage();
    final lang = selectedLang?['language'] ?? 'en';
    final country = selectedLang?['country'] ?? 'US';
    final fullLangCode = '${lang}_$country';
    options.headers['x-app-language'] = fullLangCode;
    super.onRequest(options, handler);
  }
}
