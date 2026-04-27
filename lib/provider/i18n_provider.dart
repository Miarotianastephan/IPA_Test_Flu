import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/api/services/i18n_service.dart';
import 'package:live_app/config/i18n_cache_manager.dart';
import 'package:live_app/config/storage_config.dart';
import 'package:live_app/models/i18n_language.dart';
import 'package:live_app/models/i18n_translation.dart';
import 'package:live_app/models/page_params.dart';
import 'package:live_app/models/page_response.dart';
import 'package:live_app/provider/api_provider.dart';
import 'package:live_app/provider/locale_provider.dart';
import 'package:live_app/utils/app_lang_version_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DownloadProgress {
  final int current;
  final int total;
  final bool isDownloading;

  DownloadProgress({
    required this.current,
    required this.total,
    this.isDownloading = false,
  });

  double get percentage => total > 0 ? (current / total * 100) : 0;

  DownloadProgress copyWith({int? current, int? total, bool? isDownloading}) {
    return DownloadProgress(
      current: current ?? this.current,
      total: total ?? this.total,
      isDownloading: isDownloading ?? this.isDownloading,
    );
  }
}

final downloadProgressProvider = StateProvider<DownloadProgress>((ref) {
  return DownloadProgress(current: 0, total: 0, isDownloading: false);
});

class I18nNotifier extends StateNotifier<AsyncValue<Map<String, String>>> {
  static const int _translationPageSize = 1000;
  final I18nService _service;
  final I18nCacheManager _cacheManager;
  final Ref _ref;

  I18nNotifier(this._ref)
    : _service = _ref.read(i18nServiceProvider),
      _cacheManager = I18nCacheManager(),
      super(const AsyncValue.loading());

  Future<void> initialize() async {
    state = const AsyncValue.loading();

    try {
      final selectedLang = await _cacheManager.loadSelectedLanguage();
      debugPrint('[I18N] initialize - selectedLang: $selectedLang');

      if (selectedLang != null) {
        final country = selectedLang['country']!;
        final langCode = selectedLang['language']!;
        debugPrint('[I18N] initialize - loading cache for: $country / $langCode');

        await _loadFromCacheForLanguage(country, langCode);

        final parts = langCode.split('_');
        final lang = parts.isNotEmpty ? parts[0] : AppLangVersionUtils.getLocaleLang();
        final countryCode = parts.length > 1
            ? parts[1]
            : AppLangVersionUtils.getLocaleCountry();

        _ref.read(localeProvider.notifier).state = Locale(lang, countryCode);

        _checkAndUpdateInBackground(langCode);
      } else {
        await _firstLaunchSetup();
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> _firstLaunchSetup() async {
    try {
      final availableLanguages = await _loadAvailableLanguagesForFirstLaunch();
      if (availableLanguages.isEmpty) {
        throw Exception('No languages available from server');
      }

      // Get system locale in a cross-platform way (works on web and mobile)
      final platformLocale = ui.PlatformDispatcher.instance.locale;
      // final systemLocale =
      //     '${platformLocale.languageCode}_${platformLocale.countryCode ?? platformLocale.languageCode.toUpperCase()}';
      // final String systemLocale;
      // systemLocale = AppLangVersionUtils.getLanguageCode();
      // debugPrint('System locale: $systemLocale');

      // Try to find exact match first (e.g., "fr_FR")
      I18nLanguage? matchingLang = availableLanguages
          .cast<I18nLanguage?>()
          .firstWhere(
            //(lang) => lang?.languageCode == systemLocale,
            (lang) => lang?.languageCode == 'en',
            orElse: () => null,
          );

      // If no exact match, try matching just the language part (e.g., "fr" matches "fr_FR")
      matchingLang ??= availableLanguages.cast<I18nLanguage?>().firstWhere(
        (lang) =>
            lang?.languageCode.startsWith('${platformLocale.languageCode}_') ==
            true,
        orElse: () => null,
      );

      // If still no match, fallback to default
      final defaultLangCode = AppLangVersionUtils.getLanguageCode();
      matchingLang ??= availableLanguages.cast<I18nLanguage?>().firstWhere(
        (lang) => lang?.languageCode == defaultLangCode,
        orElse: () => null,
      );

      // Ultimate fallback: use first available language
      final langToDownload = matchingLang ?? availableLanguages.first;

      final actualLanguage = await _downloadAndSaveLanguage(
        langToDownload,
        isInitial: true,
      );

      await _cacheManager.saveSelectedLanguage(
        actualLanguage.countryName,
        actualLanguage.languageCode,
      );

      if (AppLangVersionUtils.isCn() || AppLangVersionUtils.isTk()) {
        final parts = actualLanguage.languageCode.split('_');
        final lang = parts.isNotEmpty ? parts[0] : 'zh';
        final countryCode = parts.length > 1 ? parts[1] : 'CN';
        _ref.read(localeProvider.notifier).state = Locale(lang, countryCode);
      } else {
        final parts = actualLanguage.languageCode.split('_');
        final lang = parts.isNotEmpty ? parts[0] : 'en';
        final countryCode = parts.length > 1 ? parts[1] : 'US';
        _ref.read(localeProvider.notifier).state = Locale(lang, countryCode);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<List<I18nLanguage>> _loadAvailableLanguagesForFirstLaunch() async {
    final sharedLanguages = await _ref.read(availableLanguagesProvider.future);
    if (sharedLanguages.isNotEmpty) {
      return sharedLanguages;
    }

    final token = StorageService.instance.getValue("token");
    if (token == null) {
      return const <I18nLanguage>[];
    }

    final response = await _service.getLanguages(PageParams(page: 1, limit: 100));
    final languages = response.data?.list ?? [];
    if (languages.isNotEmpty) {
      await _cacheManager.saveAvailableLanguages(languages);
    }
    return languages;
  }

  Future<void> changeLanguage(I18nLanguage language) async {
    try {
      debugPrint('[I18N] changeLanguage - requested: ${language.languageCode} (${language.countryName})');
      I18nLanguage actualLanguage = language;

      final isDownloaded = await _cacheManager.isLanguageDownloaded(
        language.countryName,
        language.languageCode,
      );
      debugPrint('[I18N] changeLanguage - isDownloaded: $isDownloaded');

      if (!isDownloaded) {
        actualLanguage = await _downloadAndSaveLanguage(language);
      }

      await _loadFromCacheForLanguage(
        actualLanguage.countryName,
        actualLanguage.languageCode,
      );

      // Save the selected language
      await _cacheManager.saveSelectedLanguage(
        actualLanguage.countryName,
        actualLanguage.languageCode,
      );
      debugPrint('[I18N] changeLanguage - saved: ${actualLanguage.languageCode}');

      final parts = actualLanguage.languageCode.split('_');
      final lang = parts.isNotEmpty ? parts[0] : AppLangVersionUtils.getLocaleLang();
      final countryCode = parts.length > 1
          ? parts[1]
          : AppLangVersionUtils.getLocaleCountry();
      _ref.read(localeProvider.notifier).state = Locale(lang, countryCode);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> downloadLanguage(I18nLanguage language) async {
    try {
      state = const AsyncValue.loading();

      final actualLanguage = await _downloadAndSaveLanguage(language);

      await changeLanguage(actualLanguage);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  ///////////////////////////////////////////////////////////////////////////
  //  CHECKING VERSION
  ///////////////////////////////////////////////////////////////////////////

  /// Check and update if needy
  Future<void> checkAndUpdate(String languageCode) async {
    try {
      final selectedLang = await _cacheManager.loadSelectedLanguage();
      if (selectedLang == null) return;
      final country = selectedLang['country']!;
      final language = selectedLang['language']!;
      final currentVersion = await _cacheManager.getCurrentVersion();

      final versionCheckResponse = await _service.checkVersion(
        country,
        language,
        currentVersion,
      );

      final versionCheck = versionCheckResponse.data;
      if (versionCheck == null) {
        return;
      }

      if (versionCheck.hasUpdate) {
        final languagesResponse = await _service.getLanguages(
          PageParams(page: 1, limit: 100),
        );
        final languages = languagesResponse.data?.list ?? [];
        final lang = languages.firstWhere(
          (l) => l.languageCode == language && l.countryName == country,
          orElse: () => throw Exception('Language not found'),
        );

        final actualLanguage = await _downloadAndSaveLanguage(lang);

        if (actualLanguage.languageCode != language) {
          final langCode = actualLanguage.languageCode; // eg: "fr_FR"
          final parts = langCode.split('_');
          final langPart = parts.isNotEmpty
              ? parts[0]
              : AppLangVersionUtils.getLocaleLang();
          final countryPart = parts.length > 1
              ? parts[1]
              : AppLangVersionUtils.getLocaleCountry();

          _ref.read(localeProvider.notifier).state = Locale(
            langPart,
            countryPart,
          );
        }
        await _loadFromCache();
      }
    } catch (e) {
      debugPrint('[I18N] Version check failed: $e (using cached version)');
    }
  }

  void _checkAndUpdateInBackground(String languageCode) {
    Future.delayed(Duration.zero, () async {
      try {
        await checkAndUpdate(languageCode);
      } catch (e) {
        debugPrint('[I18N] Background version check failed: $e');
      }
    });
  }

  Future<void> _loadFromCache() async {
    final translationsList = await _cacheManager.loadTranslations();

    if (translationsList == null || translationsList.isEmpty) {
      state = const AsyncValue.data({});
      return;
    }

    final translations = <String, String>{};
    for (final translation in translationsList) {
      translations[translation.key] = translation.translationValue;
    }

    state = AsyncValue.data(translations);
  }

  Future<void> _loadFromCacheForLanguage(
    String country,
    String language,
  ) async {
    final translationsList = await _cacheManager.loadTranslationsForLanguage(
      country,
      language,
    );

    if (translationsList == null || translationsList.isEmpty) {
      state = const AsyncValue.data({});
      return;
    }

    final translations = <String, String>{};
    for (final translation in translationsList) {
      translations[translation.key] = translation.translationValue;
    }

    state = AsyncValue.data(translations);
  }

  Future<I18nLanguage> _downloadAndSaveLanguage(
    I18nLanguage language, {
    bool isInitial = false,
  }) async {
    _ref.read(downloadProgressProvider.notifier).state = DownloadProgress(
      current: 0,
      total: 0,
      isDownloading: true,
    );

    try {
      if (isInitial) {
        // Download first page to let the app start quickly
        final firstPage = await _downloadTranslationsPage(
          1,
          language.countryName,
          language.languageCode,
        );

        final defaultLangCode = AppLangVersionUtils.getLanguageCode();
        if (firstPage.list.isEmpty &&
            language.languageCode != defaultLangCode) {
          // Fallback to default language if initial fails
          final fallbackLang = await _getDefaultLanguage();
          return _downloadAndSaveLanguage(fallbackLang, isInitial: true);
        }

        // Apply first page immediately
        final initialTranslations = <String, String>{};
        for (final t in firstPage.list) {
          initialTranslations[t.key] = t.translationValue;
        }
        state = AsyncValue.data(initialTranslations);

        // Continue rest in background
        _downloadRemainingTranslations(
          language,
          firstPage.list,
          firstPage.total,
        );

        return language;
      } else {
        final languageTranslations = await _downloadTranslationsForLanguage(
          language.countryName,
          language.languageCode,
          language.displayName,
        );

        I18nLanguage actualLanguage = language;
        List<I18nTranslation> finalTranslations = languageTranslations;

        final defaultLangCode = AppLangVersionUtils.getLanguageCode();
        if (languageTranslations.isEmpty &&
            language.languageCode != defaultLangCode) {
          final fallbackLang = await _getDefaultLanguage();
          finalTranslations = await _downloadTranslationsForLanguage(
            fallbackLang.countryName,
            fallbackLang.languageCode,
            fallbackLang.displayName,
          );
          actualLanguage = fallbackLang;
        }

        await _cacheManager.saveTranslations(finalTranslations, actualLanguage);
        await _loadFromCache();
        return actualLanguage;
      }
    } catch (e) {
      rethrow;
    } finally {
      if (!isInitial) {
        _ref.read(downloadProgressProvider.notifier).state = DownloadProgress(
          current: 0,
          total: 0,
          isDownloading: false,
        );
      }
    }
  }

  Future<void> _downloadRemainingTranslations(
    I18nLanguage language,
    List<I18nTranslation> alreadyDownloaded,
    int total,
  ) async {
    if (alreadyDownloaded.length >= total) {
      await _cacheManager.saveTranslations(alreadyDownloaded, language);
      return;
    }

    Future.microtask(() async {
      try {
        final allTranslations = List<I18nTranslation>.from(alreadyDownloaded);
        int currentPage = 2;

        while (allTranslations.length < total) {
          final pageResponse = await _downloadTranslationsPage(
            currentPage,
            language.countryName,
            language.languageCode,
          );

          if (pageResponse.list.isEmpty) break;

          allTranslations.addAll(pageResponse.list);

          // Update state immediately to reflect new translations
          final currentMap = state.value ?? {};
          final updatedMap = Map<String, String>.from(currentMap);
          for (final t in pageResponse.list) {
            updatedMap[t.key] = t.translationValue;
          }
          state = AsyncValue.data(updatedMap);

          _ref.read(downloadProgressProvider.notifier).state = DownloadProgress(
            current: allTranslations.length,
            total: total,
            isDownloading: true,
          );

          currentPage++;
        }

        await _cacheManager.saveTranslations(allTranslations, language);
      } catch (e) {
        debugPrint('[I18N] Background download failed: $e');
      } finally {
        _ref.read(downloadProgressProvider.notifier).state = DownloadProgress(
          current: 0,
          total: 0,
          isDownloading: false,
        );
      }
    });
  }

  Future<PageResponse<I18nTranslation>> _downloadTranslationsPage(
    int page,
    String country,
    String languageCode,
  ) async {
    final response = await _service.getTranslations(
      PageParams(page: page, limit: _translationPageSize),
      country,
      languageCode,
    );

    final data = response.data;
    if (data == null) throw Exception('Translation API returned null');
    return data;
  }

  Future<List<I18nTranslation>> _downloadTranslationsForLanguage(
    String country,
    String languageCode,
    String displayName,
  ) async {
    final allTranslations = <I18nTranslation>[];
    int currentPage = 1;
    const pageSize = _translationPageSize;
    int total = 0;

    do {
      final response = await _service.getTranslations(
        PageParams(page: currentPage, limit: pageSize),
        country,
        languageCode,
      );

      final pageResponse = response.data;
      if (pageResponse == null) {
        throw Exception('Translation API returned null');
      }

      if (total == 0) {
        total = pageResponse.total;
      }

      allTranslations.addAll(pageResponse.list);

      _ref.read(downloadProgressProvider.notifier).state = DownloadProgress(
        current: allTranslations.length,
        total: total,
        isDownloading: true,
      );

      currentPage++;
    } while (allTranslations.length < total && total > 0);

    return allTranslations;
  }

  Future<I18nLanguage> _getDefaultLanguage() async {
    final defaultLangCode = AppLangVersionUtils.getLanguageCode();
    final languagesResponse = await _service.getLanguages(
      PageParams(page: 1, limit: 100),
    );
    final languages = languagesResponse.data?.list ?? [];
    final defaultLang = languages.firstWhere(
      (lang) => lang.languageCode == defaultLangCode,
      orElse: () =>
          throw Exception('Default language $defaultLangCode not found'),
    );
    return defaultLang;
  }

  String translate(String key, {String? fallback}) {
    final result = state.when(
      data: (translations) {
        final value = translations[key] ?? fallback ?? key;
        return value;
      },
      loading: () {
        return fallback ?? key;
      },
      error: (_, __) {
        return fallback ?? key;
      },
    );
    return result;
  }
}

// Main provider state for i18n
final i18nNotifierProvider =
    StateNotifierProvider<I18nNotifier, AsyncValue<Map<String, String>>>((ref) {
      return I18nNotifier(ref);
    });

// Provider for the list of available languages (with persistent cache)
final availableLanguagesProvider = FutureProvider<List<I18nLanguage>>((
  ref,
) async {
  final cacheManager = I18nCacheManager();

  final cachedLanguages = await cacheManager.loadAvailableLanguages();
  final isCacheExpired = await cacheManager.isAvailableLanguagesCacheExpired();

  if (cachedLanguages != null && !isCacheExpired) {
    final cacheTime = await SharedPreferences.getInstance().then(
      (prefs) => prefs.getInt('i18n_available_languages_cache_time'),
    );
    if (cacheTime != null) {
      final hoursSinceCache = DateTime.now()
          .difference(DateTime.fromMillisecondsSinceEpoch(cacheTime))
          .inHours;
      if (hoursSinceCache >= 20) {
        _refreshAvailableLanguagesInBackground(ref);
      }
    }

    return cachedLanguages;
  }

  // Check if user is authenticated before calling API
  final token = StorageService.instance.getValue("token");
  if (token == null) {
    return cachedLanguages ?? [];
  }

  try {
    final service = ref.watch(i18nServiceProvider);
    final response = await service.getLanguages(
      PageParams(page: 1, limit: 100),
    );

    final languages = response.data?.list ?? [];

    if (languages.isNotEmpty) {
      await cacheManager.saveAvailableLanguages(languages);
    }

    return languages;
  } catch (e, stack) {
    debugPrint(
      '[I18N] availableLanguagesProvider: Error fetching languages: $e',
    );
    debugPrint('[I18N] availableLanguagesProvider: Stack: $stack');
    if (cachedLanguages != null) {
      return cachedLanguages;
    }

    return [];
  }
});

void _refreshAvailableLanguagesInBackground(Ref ref) {
  Future.delayed(Duration.zero, () async {
    try {
      final service = ref.read(i18nServiceProvider);
      final response = await service.getLanguages(
        PageParams(page: 1, limit: 100),
      );
      final languages = response.data?.list ?? [];

      if (languages.isNotEmpty) {
        final cacheManager = I18nCacheManager();
        await cacheManager.saveAvailableLanguages(languages);

        ref.invalidate(availableLanguagesProvider);
      }
    } catch (e) {
      debugPrint('[I18N] Background refresh failed: $e');
    }
  });
}

// Selected language's provider
final selectedLanguageProvider = FutureProvider<Map<String, String>?>((
  ref,
) async {
  final cacheManager = I18nCacheManager();
  return await cacheManager.loadSelectedLanguage();
});

// Current version's provider
final currentVersionProvider = FutureProvider<String>((ref) async {
  final cacheManager = I18nCacheManager();
  return await cacheManager.getCurrentVersion();
});

// Downloaded language's provider (auto-refresh)
final downloadedLanguagesProvider = FutureProvider.autoDispose<List<String>>((
  ref,
) async {
  final cacheManager = I18nCacheManager();
  return await cacheManager.getDownloadedLanguages();
});
