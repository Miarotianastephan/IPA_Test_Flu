import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/app_config.dart';
import 'package:live_app/page/maintenance_page.dart';
import 'package:live_app/provider/app_config_provider.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/provider/my_user_provider.dart';
import 'package:live_app/utils/app_lang_version_utils.dart';
import 'package:live_app/utils/icon_utils.dart';
import 'package:live_app/utils/web_hls_loader.dart';
import 'package:live_app/widgets/encrypted_image.dart';
import 'package:live_app/widgets/loading_dots.dart';

import '../api/api_client.dart';
import '../api/services/version_service.dart';
import '../config/storage_config.dart';
import '../provider/api_provider.dart';
import '../provider/current_user_provider.dart';
import '../provider/domain_provider.dart';
import 'force_update_page.dart';
import 'home.dart' deferred as home;

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  static const bool _blockHomeNavigationForStartupDebug = false;

  double _opacity = 1.0;
  String? _i18nStatus;
  bool _showOfflineScreen = false;
  bool _isRetrying = false;

  String _translate(String key) =>
      ref.read(i18nNotifierProvider.notifier).translate(key);

  void _refreshAvailableLanguagesIfNeeded() {
    final languagesState = ref.read(availableLanguagesProvider);
    final shouldInvalidate = languagesState.when(
      data: (languages) => languages.isEmpty,
      loading: () => false,
      error: (_, __) => true,
    );

    if (shouldInvalidate) {
      ref.invalidate(availableLanguagesProvider);
    }
  }

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _init() async {
    // 1. Auth — token refresh or visitor login (needed for i18n)
    final currentUserNotifier = ref.read(currentUserProvider.notifier);
    final token = StorageService.instance.getValue("token");
    bool initialized = false;
    bool hasNetworkError = false;

    if (token != null) {
      // 已有 token，尝试刷新
      try {
        final res = await currentUserNotifier.refreshToken();
        if (res?.data != null) {
          initialized = true;
        }
      } catch (e) {
        hasNetworkError = _isNetworkError(e);
      }
    }

    if (!initialized) {
      // 没有 token 或刷新失败，走游客登录
      try {
        final res = await currentUserNotifier.recordFirstOpen();
        if (res?.data != null) {
          await currentUserNotifier.visitorLogin(
            res!.data!.idFirstOpen!,
            res.data?.userId,
          );
        }
      } catch (e) {
        hasNetworkError = _isNetworkError(e);
      }
    }

    if (hasNetworkError) {
      if (mounted) {
        setState(() {
          _showOfflineScreen = true;
          _isRetrying = false;
        });
      }
      return;
    }

    if (mounted && _showOfflineScreen) {
      setState(() {
        _showOfflineScreen = false;
      });
    }

    try {
      setState(() {
        _i18nStatus = _translate('downloadingTranslations');
      });
      _refreshAvailableLanguagesIfNeeded();
      await ref.read(i18nNotifierProvider.notifier).initialize();
      setState(() {
        _i18nStatus = _translate('translationsLoaded');
      });
    } catch (e) {
      setState(() {
        _i18nStatus = _translate('errorLoadingTranslations');
      });
    }

    try {
      final versionService = VersionService(ApiClient.instance);
      final result = await versionService.checkForForceUpdate();

      if (result.forceInstall && result.version != null && mounted) {
        final domainLanding = ref.read(domainProvider).domain?.landing;
        final String landingUrl;
        if (domainLanding != null && domainLanding.isNotEmpty) {
          landingUrl = domainLanding;
        } else {
          landingUrl = 'https://landing.99sq20.fun';
        }

        Navigator.of(context, rootNavigator: true).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ForceUpdatePage(
              version: result.version!,
              currentVersion: result.currentVersion,
              landingUrl: landingUrl,
            ),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (_, animation, _, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
        return;
      }
    } catch (e) {
      debugPrint("Force update check failed: $e");
    }

    _trackInstallationInBackground();

    await getAppConfig();
  }

  void _trackInstallationInBackground() {
    unawaited(() async {
      try {
        final installationService = ref.read(
          installationTrackingServiceProvider,
        );
        final userInfo = ref.read(userProvider);
        await installationService.trackInstallationIfNeeded(
          userId: userInfo.user?.id.toString(),
        );
      } catch (e) {}
    }());
  }

  bool _isNetworkError(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    return errorStr.contains('connection') ||
        errorStr.contains('network') ||
        errorStr.contains('timeout') ||
        errorStr.contains('socketexception');
  }

  bool _shouldBlockHomeNavigation(String source, Map<String, dynamic>? config) {
    if (!_blockHomeNavigationForStartupDebug) {
      return false;
    }

    debugPrint(
      '[SplashPage] Blocked navigation to HomePage for startup profiling. '
      'source=$source configKeys=${config?.keys.toList() ?? const []}',
    );
    return true;
  }

  Future<void> getAppConfig() async {
    final appService = ref.read(appServiceProvider);

    try {
      final appConfig = await appService.appConfig();
      if (kIsWeb) setAppIconFromUrl(appConfig.data?['favicon_url']);

      await StorageService.instance.setValue(
        "app_config",
        jsonEncode(appConfig.data),
      );

      ref
          .read(appConfigProvider.notifier)
          .updateConfig(AppConfig.fromJson(appConfig.data!));

      if (!mounted) return;

      final navigator = Navigator.of(context, rootNavigator: true);

      void navigateTo(Widget page) {
        navigator.pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, _, _) => page,
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (_, animation, _, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }

      Future<void> navigateToHome(Map<String, dynamic>? config) async {
        if (_shouldBlockHomeNavigation('remote_config', config)) {
          return;
        }
        await Future.wait([home.loadLibrary(), preloadWebHlsForHome()]);
        if (!mounted) return;
        navigateTo(home.HomePage(config: config));
      }

      String? platformKey;
      if (kIsWeb) {
        platformKey = 'enable_web';
      } else if (Platform.isAndroid) {
        platformKey = 'enable_android';
      } else if (Platform.isIOS) {
        platformKey = 'enable_ios';
      }

      if (platformKey != null) {
        final enabled = (appConfig.data?[platformKey] as bool?) ?? false;
        if (!enabled) {
          navigateTo(MaintenancePage(isChatPage: false));
        } else {
          if (AppLangVersionUtils.isYd()) {
            Navigator.of(context, rootNavigator: true)
                .push(
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => _CountdownDialog(),
                    transitionDuration: Duration.zero,
                    barrierDismissible: false,
                    opaque: true,
                  ),
                )
                .then((_) {
                  if (mounted) {
                    unawaited(navigateToHome(appConfig.data));
                  }
                });
          } else {
            await navigateToHome(appConfig.data);
          }
        }
      }
    } catch (e) {
      final cachedConfig = StorageService.instance.getValue("app_config");
      if (cachedConfig != null && mounted) {
        try {
          final configData = jsonDecode(cachedConfig);
          ref.read(appConfigProvider.notifier).updateConfig(configData);

          if (_shouldBlockHomeNavigation('cached_config', configData)) {
            return;
          }
          await Future.wait([home.loadLibrary(), preloadWebHlsForHome()]);
          if (!mounted) return;
          final navigator = Navigator.of(context, rootNavigator: true);
          navigator.pushReplacement(
            PageRouteBuilder(
              pageBuilder: (_, _, _) => home.HomePage(config: configData),
              transitionDuration: const Duration(milliseconds: 500),
              transitionsBuilder: (_, animation, _, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );

          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_translate('usingCachedConfig')),
                  duration: const Duration(seconds: 3),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          });
        } catch (cacheError) {}
      }
    }
  }

  Future<void> _initApp() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await Future.wait([
          Future.delayed(const Duration(seconds: 1)),
          _init(),
        ]);

        if (!mounted) return;

        setState(() => _opacity = 0);

        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = constraints.maxHeight;
          final screenWidth = constraints.maxWidth;

          if (_showOfflineScreen) {
            return _buildOfflineScreen(screenHeight, screenWidth);
          }

          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: AppLangVersionUtils.isCn()
                      ? null
                      : DecorationImage(
                          image: AssetImage(
                            AppLangVersionUtils.getBackgroundLogoPath(),
                          ),
                          fit: BoxFit.fill,
                        ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    EncryptedImage(
                      url: ref.read(appConfigProvider).data?.faviconUrl ?? "",
                      height: screenHeight * 0.1,
                      errorWidget: Image.asset(
                        AppLangVersionUtils.getLogoPath(),
                        height: screenHeight * 0.1,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const LoadingDots(),
                    // if (_i18nStatus != null) ...[
                    //   const SizedBox(height: 8),
                    //   Text(
                    //     _i18nStatus!,
                    //     style: const TextStyle(
                    //       color: Colors.white70,
                    //       fontSize: 12,
                    //     ),
                    //   ),
                    // ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOfflineScreen(double screenHeight, double screenWidth) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 0, 0, 0),
            Color.fromARGB(255, 10, 10, 20),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 4),
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 80,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              _translate('noInternetConnection'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                _translate('checkConnectionAndRetry'),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 1),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _translate('troubleshootingTips'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTipItem(_translate('tipCheckWifi')),
                  const SizedBox(height: 8),
                  _buildTipItem(_translate('tipAirplaneMode')),
                  const SizedBox(height: 8),
                  _buildTipItem(_translate('tipBetterSignal')),
                ],
              ),
            ),
            const Spacer(flex: 3),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isRetrying
                      ? null
                      : () async {
                          setState(() {
                            _isRetrying = true;
                          });
                          await _init();
                          if (mounted) {
                            setState(() {
                              _isRetrying = false;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isRetrying
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 12),
                            Text(
                              _translate('tryAgain'),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.7),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _CountdownDialog extends StatefulWidget {
  const _CountdownDialog();

  @override
  State<_CountdownDialog> createState() => _CountdownDialogState();
}

class _CountdownDialogState extends State<_CountdownDialog> {
  int _countdown = 3;
  bool _showCloseButton = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _countdown--;
          if (_countdown <= 0) {
            _showCloseButton = true;
            _closeDialog();
            timer.cancel();
          }
        });
      }
    });
  }

  void _closeDialog() {
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: AppLangVersionUtils.isCn()
                      ? null
                      : DecorationImage(
                          image: AssetImage(
                            AppLangVersionUtils.getBackgroundLogoPath(),
                          ),
                          fit: BoxFit.fill,
                        ),
                ),
              ),
              if (!_showCloseButton)
                Positioned(
                  top: 50,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$_countdown',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              if (_showCloseButton)
                Positioned(
                  top: 50,
                  right: 20,
                  child: GestureDetector(
                    onTap: _closeDialog,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 21,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
