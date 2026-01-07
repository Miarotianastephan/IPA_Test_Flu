import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/i18n_language.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/provider/locale_provider.dart';

class MaintenancePage extends ConsumerStatefulWidget {
  const MaintenancePage({super.key, required this.isChatPage});
  final bool isChatPage;

  @override
  ConsumerState<MaintenancePage> createState() => _MaintenancePageState();
}

class _MaintenancePageState extends ConsumerState<MaintenancePage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final i18nNotifier = ref.read(i18nNotifierProvider.notifier);
    final availableLanguagesAsync = ref.watch(availableLanguagesProvider);
    final downloadedLanguagesAsync = ref.watch(downloadedLanguagesProvider);
    final currentLocale = ref.watch(localeProvider);

    String translate(String key) => i18nNotifier.translate(key);

    String message;
    if (kIsWeb) {
      message = translate('maintenanceWeb');
    } else if (Platform.isAndroid || Platform.isIOS) {
      message = translate('maintenanceMobile');
    } else {
      message = translate('maintenanceService');
    }

    return Scaffold(
      backgroundColor: Colors.black87,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: [
          if (!widget.isChatPage)
            availableLanguagesAsync.when(
              data: (languages) {
                return downloadedLanguagesAsync.when(
                  data: (downloadedLanguageCodes) {
                    final downloadedLanguages = languages.where((lang) {
                      return downloadedLanguageCodes.contains(
                        lang.languageCode,
                      );
                    }).toList();

                    if (downloadedLanguages.isEmpty) {
                      return const SizedBox();
                    }

                    final currentLang = downloadedLanguages.firstWhere((lang) {
                      final parts = lang.languageCode.split('_');
                      final langCode = parts.isNotEmpty
                          ? parts[0]
                          : lang.languageCode;
                      return langCode == currentLocale.languageCode;
                    }, orElse: () => downloadedLanguages.first);

                    return PopupMenuButton<I18nLanguage>(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              currentLang.displayName,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      onSelected: (language) async {
                        await ref
                            .read(i18nNotifierProvider.notifier)
                            .changeLanguage(language);
                      },
                      itemBuilder: (context) => downloadedLanguages
                          .map(
                            (lang) => PopupMenuItem(
                              value: lang,
                              child: Text(lang.displayName),
                            ),
                          )
                          .toList(),
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: CircularProgressIndicator(
                      color: Colors.white70,
                      strokeWidth: 2,
                    ),
                  ),
                  error: (error, _) => const SizedBox(),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: CircularProgressIndicator(
                  color: Colors.white70,
                  strokeWidth: 2,
                ),
              ),
              error: (error, _) => const SizedBox(),
            ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              const Icon(Icons.construction, size: 80, color: Colors.white),
              const SizedBox(height: 30),
              Text(
                translate('underMaintenance'),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                message,
                style: const TextStyle(fontSize: 16, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              if (!kIsWeb && !widget.isChatPage) ...[
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.onSecondary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      SystemNavigator.pop();
                    },
                    child: Text(
                      translate('quitApp'),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
