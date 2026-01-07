class I18nApi {
  static const String base = "/api/user/i18n";
  static const String getLanguages = '$base/languages';
  static const String getTranslations = '$base/translationData/byCountryCode';
  static const String checkVersion = '$base/version/check';
}
