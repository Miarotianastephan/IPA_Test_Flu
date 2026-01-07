import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/i18n_cache_manager.dart';

final localeProvider = StateProvider<Locale>((ref) => const Locale('en', 'US'));

final initializeLocaleProvider = FutureProvider<void>((ref) async {
  final cacheManager = I18nCacheManager();
  final selectedLang = await cacheManager.loadSelectedLanguage();
  final langCode = selectedLang?['language'] ?? 'en_US';

  final parts = langCode.split('_');
  final language = parts.isNotEmpty ? parts[0] : 'en';
  final country = parts.length > 1 ? parts[1] : 'US';

  ref.read(localeProvider.notifier).state = Locale(language, country);
});
