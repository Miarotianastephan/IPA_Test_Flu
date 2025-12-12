import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:live_app/l10n/app_localizations.dart';
import 'package:live_app/provider/locale_provider.dart';
import 'package:live_app/api/services/version_component.dart';
import 'package:live_app/config/storage_config.dart';
import 'package:live_app/models/version.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  String _currentVersion = '';
  Version? _latestVersion;
  bool _isCheckingUpdate = false;

  @override
  void initState() {
    super.initState();
    _loadVersionInfo();
  }

  Future<void> _loadVersionInfo() async {
    try {
      final currentVersion = await VersionComponent.getCurrentVersion();
      setState(() {
        _currentVersion = currentVersion;
      });
    } catch (e) {
      debugPrint('Error loading version: $e');
    }
  }

  Future<void> _checkForUpdates() async {
    setState(() {
      _isCheckingUpdate = true;
    });

    try {
      final latestVersion = await VersionComponent.fetchVersion();
      final currentVersion = await VersionComponent.getCurrentVersion();

      if (latestVersion != null && mounted) {
        final updateAvailable = VersionComponent.isUpdateAvailable(
          latestVersion.versionNumber,
          currentVersion,
        );

        setState(() {
          _latestVersion = latestVersion;
          _currentVersion = currentVersion;
          _isCheckingUpdate = false;
        });

        if (updateAvailable) {
          _showUpdateDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.appUpToDate),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingUpdate = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.error}: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showUpdateDialog() {
    final localisations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          localisations.newVersionAvailable,
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${localisations.currentVersion} :\n$_currentVersion'),
            const SizedBox(height: 8),
            Text(
              '${localisations.latestVersion} : \n${_latestVersion?.versionNumber}',
            ),
            if (_latestVersion?.description != null) ...[
              const SizedBox(height: 12),
              Text(localisations.description),
              const SizedBox(height: 4),
              Text(_latestVersion!.description!),
            ],
            if (_latestVersion?.dateRelease != null) ...[
              const SizedBox(height: 8),
              Text(
                '${localisations.releaseDate}:\n${_latestVersion!.dateRelease}',
              ),
            ],
          ],
        ),
        actions: [
          if (_shouldShowDownloadButton())
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.onSecondary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _launchDownloadUrl();
                },
                icon: Platform.isIOS
                    ? Icon(Icons.apple, color: Colors.white)
                    : Platform.isAndroid
                    ? Icon(Icons.android, color: Colors.green)
                    : null,
                label: Text(localisations.download),
              ),
            ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.onSecondary,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },

            child: Text(localisations.cancel),
          ),
        ],
      ),
    );
  }

  bool _shouldShowDownloadButton() {
    if (_latestVersion == null) return false;

    final hasAndroid =
        _latestVersion!.urlAndroid != null &&
        _latestVersion!.urlAndroid!.isNotEmpty;
    final hasIos =
        _latestVersion!.urlIos != null && _latestVersion!.urlIos!.isNotEmpty;

    return hasAndroid || hasIos;
  }

  Future<void> _launchDownloadUrl() async {
    if (_latestVersion == null) return;

    final url = Theme.of(context).platform == TargetPlatform.iOS
        ? _latestVersion!.urlIos
        : _latestVersion!.urlAndroid;

    if (url != null && url.isNotEmpty) {
      final baseUrl = dotenv.env['R2_URL'];
      final uri = Uri.parse("$baseUrl$url");

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.error),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    final localisations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(localisations.settings),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: Text(localisations.language),
                  trailing: DropdownButton<Locale>(
                    value: currentLocale,
                    items: const [
                      DropdownMenuItem(
                        value: Locale('en'),
                        child: Text('English'),
                      ),
                      DropdownMenuItem(
                        value: Locale('es'),
                        child: Text('Español'),
                      ),
                      DropdownMenuItem(value: Locale('zh'), child: Text('中文')),
                    ],
                    onChanged: (locale) {
                      if (locale != null) {
                        WidgetsBinding.instance.addPostFrameCallback((_) async {
                          ref.read(localeProvider.notifier).state = locale;

                          await StorageService.instance.setValue(
                            'lang',
                            locale.languageCode,
                          );
                        });
                      }
                    },
                  ),
                ),
                ListTile(
                  title: Text(localisations.checkForUpdates),
                  trailing: _isCheckingUpdate
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(Icons.refresh),
                  onTap: _isCheckingUpdate ? null : _checkForUpdates,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  localisations.version,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  _currentVersion.isNotEmpty ? _currentVersion : '...',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
