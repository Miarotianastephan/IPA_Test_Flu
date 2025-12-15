import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/config/storage_config.dart';
import 'package:live_app/l10n/app_localizations.dart';
import 'package:live_app/provider/locale_provider.dart';

class MaintenancePage extends ConsumerStatefulWidget {
  const MaintenancePage({super.key, required this.enabledWeb});
  final bool enabledWeb;
  @override
  ConsumerState<MaintenancePage> createState() => _MaintenancePageState();
}

class _MaintenancePageState extends ConsumerState<MaintenancePage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String message;
    if (kIsWeb) {
      message = AppLocalizations.of(context)!.maintenance_web;
    } else if (Platform.isAndroid || Platform.isIOS) {
      message = AppLocalizations.of(context)!.maintenance_mobile;
    } else {
      message = AppLocalizations.of(context)!.maintenance_service;
    }

    String localeName(Locale locale) {
      switch (locale.languageCode) {
        case 'en':
          return 'English';
        case 'es':
          return 'Español';
        case 'zh':
          return '中文';
        default:
          return locale.languageCode;
      }
    }

    return Scaffold(
      backgroundColor: Colors.black87,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: [
          PopupMenuButton<Locale>(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  const Icon(Icons.arrow_drop_down, color: Colors.white70),
                  const SizedBox(width: 6),
                  Text(
                    localeName(ref.watch(localeProvider)),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            onSelected: (locale) async {
              ref.read(localeProvider.notifier).state = locale;
              await StorageService.instance.setValue(
                'lang',
                locale.languageCode,
              );
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: Locale('en'), child: Text('English')),
              const PopupMenuItem(value: Locale('es'), child: Text('Español')),
              const PopupMenuItem(value: Locale('zh'), child: Text('中文')),
            ],
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
              Icon(Icons.construction, size: 80, color: Colors.white),
              const SizedBox(height: 30),
              Text(
                AppLocalizations.of(context)!.underMaintenance,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                message,
                style: TextStyle(fontSize: 16, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
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
                    //Launch URL to download app or open browser
                  },
                  child: Text(
                    widget.enabledWeb == true
                        ? AppLocalizations.of(context)!.downloadApp
                        : AppLocalizations.of(context)!.useBrowser,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
