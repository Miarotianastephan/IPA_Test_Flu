import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/api/services/version_service.dart';
import 'package:live_app/models/version.dart';
import 'package:live_app/page/my/language_selection_page.dart';
import 'package:live_app/provider/api_provider.dart';
import 'package:live_app/provider/domain_provider.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/repository/image_repository.dart';
import 'package:live_app/utils/toast_util.dart';
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
  String _cacheSize = '...';

  @override
  void initState() {
    super.initState();
    _loadVersionInfo();
    _loadCacheSize();
  }

  Future<void> _loadVersionInfo() async {
    try {
      final currentVersion = await VersionService.getCurrentVersion();
      setState(() {
        _currentVersion = currentVersion;
      });
    } catch (e) {
      debugPrint('Error loading version: $e');
    }
  }

  Future<void> _loadCacheSize() async {
    try {
      final imageRepo = ref.read(imageRepositoryProvider);
      final stats = await imageRepo.getCacheStats();
      if (mounted) {
        setState(() {
          _cacheSize = stats.formattedSize;
        });
      }
    } catch (e) {
      debugPrint('Error loading cache size: $e');
    }
  }

  Future<void> _clearCache() async {
    try {
      final imageRepo = ref.read(imageRepositoryProvider);
      await imageRepo.clearCache();

      if (mounted) {
        final i18n = ref.read(i18nNotifierProvider.notifier);
        ToastUtil.success(i18n.translate('cacheCleared'));
        await _loadCacheSize();
      }
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  Future<void> _checkForUpdates() async {
    final i18n = ref.read(i18nNotifierProvider.notifier);

    setState(() {
      _isCheckingUpdate = true;
    });

    try {
      final versionService = ref.read(versionServiceProvider);
      final latestVersion = await versionService.fetchVersion();
      final currentVersion = await VersionService.getCurrentVersion();

      setState(() {
        _isCheckingUpdate = false;
      });

      if (latestVersion == null) {
        ToastUtil.info(i18n.translate('noVersionAvailableAtTheMoment'));
        return;
      }

      if (mounted) {
        final updateAvailable = VersionService.isUpdateAvailable(
          latestVersion.versionNumber,
          currentVersion,
        );

        setState(() {
          _latestVersion = latestVersion;
          _currentVersion = currentVersion;
        });

        if (updateAvailable) {
          _showUpdateDialog();
        } else {
          ToastUtil.success(i18n.translate('appUpToDate'));
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingUpdate = false;
        });
        ToastUtil.error('${i18n.translate('error')}: $e');
      }
    }
  }

  void _showUpdateDialog() {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          translate('newVersionAvailable'),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${translate('currentVersion')} :\n$_currentVersion'),
            const SizedBox(height: 8),
            Text(
              '${translate('latestVersion')} : \n${_latestVersion?.versionNumber}',
            ),
            if (_latestVersion?.description != null) ...[
              const SizedBox(height: 12),
              Text(translate('description')),
              const SizedBox(height: 4),
              Text(_latestVersion!.description!),
            ],
            if (_latestVersion?.dateRelease != null) ...[
              const SizedBox(height: 8),
              Text(
                '${translate('releaseDate')}:\n${_latestVersion!.dateRelease}',
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
                label: Text(translate('download')),
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

            child: Text(translate('cancel')),
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
      final baseUrl = ref.read(domainProvider).domain?.storage;
      final uri = Uri.parse("$baseUrl$url");

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          final i18n = ref.read(i18nNotifierProvider.notifier);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(i18n.translate('error')),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(translate('settings')),
          backgroundColor: Colors.black,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    title: Text(translate('language')),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LanguageSelectionPage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: Text(translate('clearCache')),
                    subtitle: Text(_cacheSize),
                    trailing: const Icon(Icons.delete_outline),
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: const Color(0xFF1A1A1A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.delete_sweep_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    translate('clearCache'),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            content: Text(
                              translate('confirmClearCache'),
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withValues(alpha: 0.7),
                                height: 1.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.fromLTRB(
                              24,
                              16,
                              24,
                              24,
                            ),
                            actionsPadding: const EdgeInsets.fromLTRB(
                              24,
                              0,
                              24,
                              24,
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.error,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size.fromHeight(40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  translate('confirm'),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm == true) {
                        await _clearCache();
                      }
                    },
                  ),
                  ListTile(
                    title: Text(translate('checkForUpdates')),
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
                    translate('version'),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentVersion.isNotEmpty ? _currentVersion : '...',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
