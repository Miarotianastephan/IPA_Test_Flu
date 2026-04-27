import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/api/services/version_service.dart';
import 'package:live_app/models/version.dart';
import 'package:live_app/page/home.dart';
import 'package:live_app/page/home_audio.dart';
import 'package:live_app/page/home_manga.dart';
import 'package:live_app/page/home_roman.dart';
import 'package:live_app/page/my/language_selection_page.dart';
import 'package:live_app/provider/api_provider.dart';
import 'package:live_app/provider/audio_provider.dart';
import 'package:live_app/provider/domain_provider.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/provider/manga_provider.dart';
import 'package:live_app/provider/roman_provider.dart';
import 'package:live_app/repository/image_repository.dart';
import 'package:live_app/utils/app_lang_version_utils.dart';
import 'package:live_app/utils/toast_util.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/storage_config.dart';
import '../../models/userinfo.dart';
import '../login/change_password.dart';
import '../my/user_info_page.dart';

enum ProfileOrigin { xo, manga, roman, audio }

class ProfileTabPage extends ConsumerStatefulWidget {
  final ProfileOrigin origin;
  final VoidCallback? onBack;
  const ProfileTabPage({super.key, required this.origin, this.onBack});

  @override
  ConsumerState<ProfileTabPage> createState() => _ProfileTabPageState();
}

class _ProfileTabPageState extends ConsumerState<ProfileTabPage> {
  UserInfo? _userInfo;
  Map<String, dynamic>? _config;
  String _currentVersion = '';
  Version? _latestVersion;
  bool _isCheckingUpdate = false;
  String _cacheSize = '...';

  String translate(String key) =>
      ref.read(i18nNotifierProvider.notifier).translate(key);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getUserFromCache();
    });
    _loadVersionInfo();
    _loadCacheSize();
  }

  Future<void> getAppConfig() async {
    final appService = ref.read(appServiceProvider);
    try {
      final appConfig = await appService.appConfig();
      await StorageService.instance.setValue("app_config", appConfig.data);
      if (!mounted) return;
      setState(() {
        _config = appConfig.data;
      });
    } catch (e, st) {
      debugPrintStack(stackTrace: st);
    }
  }

  Future<void> getUserFromCache() async {
    final data = await StorageService.instance.getValue("user_info");
    if (data != null && data.isNotEmpty) {
      final map = data is String ? jsonDecode(data) : data;
      setState(() {
        _userInfo = UserInfo.fromJson(map);
      });
    }
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

  void _navigate(BuildContext context, Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    await getUserFromCache();
  }

  void _pushUntil(BuildContext context, Widget page) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => page),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);

    final theme = Theme.of(context);
    if (_userInfo == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    final List<Widget> extraTiles = [];

    switch (widget.origin) {
      case ProfileOrigin.xo:
        // extraTiles.addAll([
        //   ListTile(
        //     leading: const Icon(Icons.menu_book_rounded),
        //     title: Text(translate("manga")),
        //     trailing: const Icon(Icons.chevron_right),
        //     onTap: () async {
        //       await getAppConfig();
        //       final response = await ref.read(mangaProvider.future);
        //       ref.checkPermission(
        //         context,
        //         Permission.accessMangaFree,
        //         () => _pushUntil(
        //           context,
        //           HomeMangaPage(items: response, config: _config),
        //         ),
        //       );
        //     },
        //   ),
        //   ListTile(
        //     leading: const Icon(Icons.menu_book_rounded),
        //     title: Text(translate("roman")),
        //     trailing: const Icon(Icons.chevron_right),
        //     onTap: () async {
        //       await getAppConfig();
        //       final response = await ref.read(romanProvider.future);
        //       ref.checkPermission(
        //         context,
        //         Permission.accessNovelFree,
        //         () => _pushUntil(
        //           context,
        //           HomeRomanPage(config: _config, items: response),
        //         ),
        //       );
        //     },
        //   ),
        //   ListTile(
        //     leading: const Icon(Icons.music_note),
        //     title: Text(translate("audio")),
        //     trailing: const Icon(Icons.chevron_right),
        //     onTap: () async {
        //       await getAppConfig();
        //       final response = await ref.read(audioProvider.future);
        //       ref.checkPermission(
        //         context,
        //         Permission.accessAudioFree,
        //         () => _pushUntil(
        //           context,
        //           HomeAudioPage(config: _config, items: response),
        //         ),
        //       );
        //     },
        //   ),
        // ]);
        break;

      case ProfileOrigin.manga:
        extraTiles.addAll([
          ListTile(
            leading: const Icon(Icons.home),
            title: Text(AppLangVersionUtils.getAppName()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await getAppConfig();
              if (!context.mounted) return;
              _pushUntil(context, HomePage(config: _config));
            },
          ),
          ListTile(
            leading: const Icon(Icons.menu_book_rounded),
            title: Text(translate("roman")),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await getAppConfig();
              final response = await ref.read(romanProvider.future);
              if (!context.mounted) return;
              _pushUntil(
                context,
                HomeRomanPage(config: _config, items: response),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.music_note),
            title: Text(translate("audio")),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await getAppConfig();
              final response = await ref.read(audioProvider.future);
              if (!context.mounted) return;
              _pushUntil(
                context,
                HomeAudioPage(config: _config, items: response),
              );
            },
          ),
        ]);
        break;

      case ProfileOrigin.roman:
        extraTiles.addAll([
          ListTile(
            leading: const Icon(Icons.home),
            title: Text(AppLangVersionUtils.getAppName()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await getAppConfig();
              if (!context.mounted) return;
              _pushUntil(context, HomePage(config: _config));
            },
          ),
          ListTile(
            leading: const Icon(Icons.menu_book_rounded),
            title: Text(translate("manga")),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await getAppConfig();
              final response = await ref.read(mangaProvider.future);
              if (!context.mounted) return;
              _pushUntil(
                context,
                HomeMangaPage(items: response, config: _config),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.music_note),
            title: Text(translate("audio")),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await getAppConfig();
              final response = await ref.read(audioProvider.future);
              if (!context.mounted) return;
              _pushUntil(
                context,
                HomeAudioPage(config: _config, items: response),
              );
            },
          ),
        ]);
        break;

      case ProfileOrigin.audio:
        extraTiles.addAll([
          ListTile(
            leading: const Icon(Icons.home),
            title: Text(AppLangVersionUtils.getAppName()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await getAppConfig();
              if (!context.mounted) return;
              _pushUntil(context, HomePage(config: _config));
            },
          ),
          ListTile(
            leading: const Icon(Icons.menu_book_rounded),
            title: Text(translate("manga")),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await getAppConfig();
              final response = await ref.read(mangaProvider.future);
              if (!context.mounted) return;
              _pushUntil(
                context,
                HomeMangaPage(items: response, config: _config),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.menu_book_rounded),
            title: Text(translate("roman")),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await getAppConfig();
              final response = await ref.read(romanProvider.future);
              if (!context.mounted) return;
              _pushUntil(
                context,
                HomeRomanPage(config: _config, items: response),
              );
            },
          ),
        ]);
        break;
    }

    return Material(
      color: Colors.black,
      child: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              color: theme.colorScheme.onPrimary,
              backgroundColor: theme.colorScheme.primary,
              onRefresh: getUserFromCache,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  if (widget.onBack != null)
                    IconButton(
                      alignment: Alignment.centerLeft,
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: widget.onBack,
                    ),

                  ...extraTiles,
                  // ListTile(
                  //   leading: Icon(Icons.account_balance_wallet_outlined),
                  //   title: Text(translate("myWallet")),
                  //   trailing: Icon(Icons.chevron_right),
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(builder: (context) => WalletPage()),
                  //     );
                  //   },
                  // ),
                  // ListTile(
                  //   leading: const Icon(Icons.shopping_bag_outlined),
                  //   title: Text(translate("myPurchases")),
                  //   trailing: const Icon(Icons.chevron_right),
                  //   onTap: () =>
                  //       _navigate(context, const PurchasedContentPage()),
                  // ),
                  // const Divider(),
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(translate("userInfo")),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        _navigate(context, UserInfoPage(user: _userInfo!)),
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock_clock_outlined),
                    title: Text(translate("changePassword")),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _navigate(context, const ChangePasswordPage()),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.language),
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
                    leading: const Icon(Icons.delete_outline),
                    title: Text(translate('clearCache')),
                    subtitle: Text(_cacheSize),
                    trailing: const Icon(Icons.chevron_right),
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
                                  backgroundColor: theme.colorScheme.error,
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
                    leading: const Icon(Icons.refresh),
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
                        : const Icon(Icons.chevron_right),
                    onTap: _isCheckingUpdate ? null : _checkForUpdates,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(translate('version'), style: theme.textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(
                  _currentVersion.isNotEmpty ? _currentVersion : '...',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
