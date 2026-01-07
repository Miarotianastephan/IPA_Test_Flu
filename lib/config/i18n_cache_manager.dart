import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/i18n_language.dart';
import '../models/i18n_translation.dart';

class I18nCacheManager {
  static const _cacheKey = 'i18n_cache';
  static const _versionKey = 'i18n_version';
  static const _languageKey = 'i18n_current_language';
  static const _downloadedLanguagesKey = 'i18n_downloaded_languages';

  /// Generate an language's unique key
  String _getLanguageKey(String country, String language) {
    return 'i18n_${country}_$language';
  }

  String _getVersionKey(String country, String language) {
    return 'i18n_version_${country}_$language';
  }

  /// 保存翻译 + 版本 - Saves translations + version
  Future<void> saveTranslations(
    List<I18nTranslation> translations,
    I18nLanguage language,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final languageKey = _getLanguageKey(
      language.countryName,
      language.languageCode,
    );
    final versionKey = _getVersionKey(
      language.countryName,
      language.languageCode,
    );

    final jsonList = translations.map((t) => t.toJson()).toList();
    final jsonString = jsonEncode(jsonList);

    await prefs.setString(languageKey, jsonString);
    await prefs.setString(versionKey, language.version);

    await prefs.setString(_cacheKey, jsonString);
    await prefs.setString(_versionKey, language.version);

    await _addToDownloadedLanguages(
      language.countryName,
      language.languageCode,
    );
  }

  /// 加载缓存的翻译 - Load cached translations
  Future<List<I18nTranslation>?> loadTranslations() async {
    final prefs = await SharedPreferences.getInstance();

    final jsonString = prefs.getString(_cacheKey);
    if (jsonString == null) return null;

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => I18nTranslation.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<List<I18nTranslation>?> loadTranslationsForLanguage(
    String country,
    String language,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final languageKey = _getLanguageKey(country, language);

    final jsonString = prefs.getString(languageKey);
    if (jsonString == null) return null;

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => I18nTranslation.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  /// 获取存储的本地版本 - Get stored local version
  Future<String> getCurrentVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_versionKey) ?? '';
  }

  Future<String> getVersionForLanguage(String country, String language) async {
    final prefs = await SharedPreferences.getInstance();
    final versionKey = _getVersionKey(country, language);
    return prefs.getString(versionKey) ?? '';
  }

  Future<void> _addToDownloadedLanguages(
    String country,
    String language,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final downloaded = await getDownloadedLanguages();

    final key = '${country}_$language';
    if (!downloaded.contains(key)) {
      downloaded.add(key);
      await prefs.setStringList(_downloadedLanguagesKey, downloaded);
    }
  }

  Future<List<String>> getDownloadedLanguages() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_downloadedLanguagesKey) ?? [];
  }

  Future<bool> isLanguageDownloaded(String country, String language) async {
    final downloaded = await getDownloadedLanguages();
    return downloaded.contains('${country}_$language');
  }

  Future<void> removeLanguage(String country, String language) async {
    final prefs = await SharedPreferences.getInstance();
    final languageKey = _getLanguageKey(country, language);
    final versionKey = _getVersionKey(country, language);

    await prefs.remove(languageKey);
    await prefs.remove(versionKey);

    final downloaded = await getDownloadedLanguages();
    downloaded.remove('${country}_$language');
    await prefs.setStringList(_downloadedLanguagesKey, downloaded);
  }

  /// 保存用户选择的语言
  Future<void> saveSelectedLanguage(String country, String language) async {
    final prefs = await SharedPreferences.getInstance();

    final payload = {"country": country, "language": language};

    await prefs.setString(_languageKey, jsonEncode(payload));
  }

  /// 加载选择的语言（如果没有则返回空值）
  Future<Map<String, String>?> loadSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();

    final jsonString = prefs.getString(_languageKey);
    if (jsonString == null) return null;

    try {
      final Map<String, dynamic> map = jsonDecode(jsonString);
      return {"country": map["country"], "language": map["language"]};
    } catch (_) {
      return null;
    }
  }

  // ===== Cache for Available Languages =====
  static const _availableLanguagesKey = 'i18n_available_languages';
  static const _availableLanguagesCacheTimeKey =
      'i18n_available_languages_cache_time';

  /// Save available languages to cache
  Future<void> saveAvailableLanguages(List<I18nLanguage> languages) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = languages.map((l) => l.toJson()).toList();
    final jsonString = jsonEncode(jsonList);

    await prefs.setString(_availableLanguagesKey, jsonString);
    await prefs.setInt(
      _availableLanguagesCacheTimeKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Load available languages from cache
  Future<List<I18nLanguage>?> loadAvailableLanguages() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_availableLanguagesKey);

    if (jsonString == null) return null;

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => I18nLanguage.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  /// Check if available languages cache is expired (older than 24 hours)
  Future<bool> isAvailableLanguagesCacheExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheTime = prefs.getInt(_availableLanguagesCacheTimeKey);

    if (cacheTime == null) return true;

    final cacheDate = DateTime.fromMillisecondsSinceEpoch(cacheTime);
    final now = DateTime.now();
    final difference = now.difference(cacheDate);

    return difference.inHours >= 24;
  }

  /// Clear available languages cache
  Future<void> clearAvailableLanguagesCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_availableLanguagesKey);
    await prefs.remove(_availableLanguagesCacheTimeKey);
  }
}
