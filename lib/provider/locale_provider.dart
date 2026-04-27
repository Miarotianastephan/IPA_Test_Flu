import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/utils/app_lang_version_utils.dart';

import '../config/i18n_cache_manager.dart';

final localeProvider = StateProvider<Locale>((ref) => Locale(
  AppLangVersionUtils.getLocaleLang(),
  AppLangVersionUtils.getLocaleCountry(),
));

final initializeLocaleProvider = FutureProvider<void>((ref) async {
  final cacheManager = I18nCacheManager();
  final selectedLang = await cacheManager.loadSelectedLanguage();
  final langCode = selectedLang?['language'] ?? AppLangVersionUtils.getLanguageCode();

  final parts = langCode.split('_');
  final language = parts.isNotEmpty ? parts[0] : AppLangVersionUtils.getLocaleLang();
  final country = parts.length > 1 ? parts[1] : AppLangVersionUtils.getLocaleCountry();

  ref.read(localeProvider.notifier).state = Locale(language, country);
});
