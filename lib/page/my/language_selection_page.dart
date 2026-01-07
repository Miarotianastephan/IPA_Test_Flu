import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/i18n_language.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/provider/locale_provider.dart';
import 'package:live_app/widgets/encrypted_image.dart';

class LanguageSelectionPage extends ConsumerStatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  ConsumerState<LanguageSelectionPage> createState() =>
      _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends ConsumerState<LanguageSelectionPage> {
  bool _isDownloading = false;
  int? _downloadingLanguageId;

  Future<void> _changeLanguage(I18nLanguage language) async {
    try {
      setState(() {
        _isDownloading = true;
        _downloadingLanguageId = language.id;
      });

      await ref.read(i18nNotifierProvider.notifier).changeLanguage(language);

      ref.invalidate(selectedLanguageProvider);

      if (mounted) {
        final i18n = ref.read(i18nNotifierProvider.notifier);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${i18n.translate('language')} changed to ${language.displayName}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final i18n = ref.read(i18nNotifierProvider.notifier);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${i18n.translate('error')}: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloadingLanguageId = null;
        });
      }
    }
  }

  Future<void> _downloadLanguage(I18nLanguage language) async {
    try {
      setState(() {
        _isDownloading = true;
        _downloadingLanguageId = language.id;
      });

      await ref.read(i18nNotifierProvider.notifier).downloadLanguage(language);

      ref.invalidate(downloadedLanguagesProvider);
      ref.invalidate(selectedLanguageProvider);
    } catch (e) {
      if (mounted) {
        final i18n = ref.read(i18nNotifierProvider.notifier);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${i18n.translate('error')}: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloadingLanguageId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    final availableLanguagesAsync = ref.watch(availableLanguagesProvider);
    final selectedLanguageAsync = ref.watch(selectedLanguageProvider);
    final downloadedLanguagesAsync = ref.watch(downloadedLanguagesProvider);
    final downloadProgress = ref.watch(downloadProgressProvider);
    final currentLocale = ref.watch(localeProvider);

    String translate(String key) => i18n.translate(key);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(translate('language')),
          backgroundColor: Colors.black,
        ),
        body: availableLanguagesAsync.when(
          data: (availableLanguages) {
            if (availableLanguages.isEmpty) {
              return Center(
                child: Text(
                  translate('noLanguagesAvailable'),
                  style: const TextStyle(color: Colors.white70),
                ),
              );
            }

            return selectedLanguageAsync.when(
              data: (selectedLang) {
                // Use the current locale from the provider to determine the selected language
                final currentLanguageCode =
                    selectedLang?['language'] ??
                    '${currentLocale.languageCode}_${currentLocale.countryCode ?? 'US'}';

                return downloadedLanguagesAsync.when(
                  data: (downloadedLanguageKeys) {
                    final downloadedLanguages = availableLanguages.where((
                      lang,
                    ) {
                      final key = '${lang.countryName}_${lang.languageCode}';
                      return downloadedLanguageKeys.contains(key);
                    }).toList();

                    // Sort downloaded languages: selected language first, then others
                    downloadedLanguages.sort((a, b) {
                      final aIsSelected = currentLanguageCode == a.languageCode;
                      final bIsSelected = currentLanguageCode == b.languageCode;

                      if (aIsSelected && !bIsSelected) return -1;
                      if (!aIsSelected && bIsSelected) return 1;
                      return a.displayName.compareTo(b.displayName);
                    });

                    final notDownloadedLanguages = availableLanguages.where((
                      lang,
                    ) {
                      final key = '${lang.countryName}_${lang.languageCode}';
                      return !downloadedLanguageKeys.contains(key);
                    }).toList();

                    return ListView(
                      children: [
                        if (downloadedLanguages.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              translate('downloadLanguages'),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          ...downloadedLanguages.map((language) {
                            final isSelected =
                                currentLanguageCode == language.languageCode;
                            final isDownloadingThis =
                                _downloadingLanguageId == language.id;

                            return ListTile(
                              leading: language.flagUrl.isNotEmpty
                                  ? EncryptedImage(
                                      key: ValueKey(language.flagUrl),
                                      url: language.flagUrl,
                                      width: 28,
                                      height: 20,
                                      fit: BoxFit.cover,
                                      errorWidget: const Icon(
                                        Icons.flag,
                                        color: Colors.grey,
                                        size: 24,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.flag,
                                      color: Colors.grey,
                                      size: 24,
                                    ),
                              title: Text(
                                language.displayName,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.blue
                                      : Colors.white,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              trailing: isDownloadingThis
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : isSelected
                                  ? const Icon(
                                      Icons.check_circle,
                                      size: 16,
                                      color: Colors.blue,
                                    )
                                  : null,
                              onTap: _isDownloading
                                  ? null
                                  : () => _changeLanguage(language),
                            );
                          }),
                        ],

                        if (notDownloadedLanguages.isNotEmpty) ...[
                          const Divider(
                            color: Color.fromARGB(255, 90, 90, 90),
                            height: 24,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              translate('availableLanguages'),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          ...notDownloadedLanguages.map((language) {
                            final isDownloadingThis =
                                _downloadingLanguageId == language.id;

                            return ListTile(
                              leading: language.flagUrl.isNotEmpty
                                  ? EncryptedImage(
                                      key: ValueKey(language.flagUrl),
                                      url: language.flagUrl,
                                      width: 28,
                                      height: 20,
                                      fit: BoxFit.cover,
                                      errorWidget: const Icon(
                                        Icons.flag,
                                        color: Colors.grey,
                                        size: 24,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.flag,
                                      color: Colors.grey,
                                      size: 24,
                                    ),
                              title: Text(
                                language.displayName,
                                style: const TextStyle(color: Colors.white70),
                              ),
                              trailing:
                                  isDownloadingThis &&
                                      downloadProgress.isDownloading
                                  ? SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              value: downloadProgress.total > 0
                                                  ? downloadProgress.current /
                                                        downloadProgress.total
                                                  : null,
                                              strokeWidth: 2,
                                              color: Colors.blue,
                                              backgroundColor: Colors.grey[800],
                                            ),
                                          ),
                                          Text(
                                            '${downloadProgress.percentage.toInt()}%',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : const Icon(
                                      Icons.download_rounded,
                                      color: Colors.white70,
                                    ),
                              onTap: _isDownloading
                                  ? null
                                  : () => _downloadLanguage(language),
                            );
                          }),
                        ],
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  error: (error, stack) => Center(
                    child: Text(
                      translate('errorLoadingDownloadedLanguages'),
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              error: (error, stack) => Center(
                child: Text(
                  translate('errorLoadingSelectedLanguages'),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  translate('errorLoadingLanguages'),
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
