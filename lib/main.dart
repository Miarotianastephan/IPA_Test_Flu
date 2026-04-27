import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/page/splash_page.dart';
import 'package:live_app/provider/domain_provider.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/utils/app_lang_version_utils.dart';
import 'package:live_app/utils/platform_check.dart';
import 'package:stack_trace/stack_trace.dart';

import 'api/api_client.dart';
import 'api/services/notification_service.dart';
import 'api/services/version_service.dart';
import 'config/storage_config.dart';
import 'provider/locale_provider.dart';
import 'provider/theme_provider.dart';
import 'services/deep_link_service.dart';
import 'utils/agent_tracking.dart';
import 'utils/app_route_observer.dart';
import 'utils/deferred_route_generator.dart';
import 'utils/toast_util.dart';
import 'utils/web_text_font.dart';
import 'utils/window_manager_wrapper.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final navigatorKey = GlobalKey<NavigatorState>();

void restartApp() {
  navigatorKey.currentState?.pushNamedAndRemoveUntil(
    '/',
    (Route<dynamic> route) => false,
  );
}

void _logUnhandledError(String source, Object error, StackTrace stackTrace) {
  debugPrint('[$source] $error');
  final normalizedStackTrace = switch (stackTrace) {
    Trace trace => trace.terse.toString(),
    Chain chain => chain.terse.toString(),
    _ => stackTrace.toString(),
  };
  debugPrint(normalizedStackTrace);
}

Future<void> main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.demangleStackTrace = (StackTrace stackTrace) {
        if (stackTrace is Trace) {
          return stackTrace.vmTrace;
        }
        if (stackTrace is Chain) {
          return stackTrace.toTrace().vmTrace;
        }
        return stackTrace;
      };

      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        _logUnhandledError(
          'FlutterError',
          details.exception,
          details.stack ?? StackTrace.current,
        );
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        _logUnhandledError('PlatformDispatcher', error, stack);
        return true;
      };

      await dotenv.load(fileName: ".env");
      final initialDomain = await DomainNotifier.fetchInitialDomain();
      setInitialDomain(initialDomain);

      final apiClient = ApiClient.instance;
      if (initialDomain.back != null) {
        apiClient.setBaseUrl(initialDomain.back!);
      }

      await StorageService.instance.init();
      await AgentTracking.captureTrackingParamsFromCurrentUri();
      if (!kIsWeb) {
        final deepLinkService = DeepLinkService();
        await deepLinkService.init();
        final initialUri = deepLinkService.initialUri;
        if (initialUri != null) {
          await AgentTracking.captureTrackingParamsFromUri(initialUri);
          deepLinkService.handlePaymentCallback(initialUri);
        }
        deepLinkService.linkStream.listen((uri) {
          unawaited(AgentTracking.captureTrackingParamsFromUri(uri));
          deepLinkService.handlePaymentCallback(uri);
        });
      }
      if (!kIsWeb) {
        await NotificationService.instance.init(
          versionService: VersionService(apiClient),
        );
      }
      await initWindowManager();
      if (!kIsWeb) await PlatformCheck.initMediaKitIfHuawei();
      try {
        await loadIosSafariCjkLiteFontIfNeeded();
      } catch (error, stackTrace) {
        _logUnhandledError('WebFontLoader', error, stackTrace);
      }
      runApp(const ProviderScope(child: MyApp()));
    },
    (error, stackTrace) {
      _logUnhandledError('runZonedGuarded', error, stackTrace);
    },
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(currentThemeProvider);
    final locale = ref.watch(localeProvider);
    final availableLanguagesAsync = ref.watch(availableLanguagesProvider);
    ref.watch(initializeLocaleProvider);

    final supportedLocales = availableLanguagesAsync.when(
      data: (languages) {
        if (languages.isEmpty) {
          return [
            Locale(
              AppLangVersionUtils.getLocaleLang(),
              AppLangVersionUtils.getLocaleCountry(),
            ),
          ];
        }
        return languages.map((lang) {
          final parts = lang.languageCode.split('_');
          return Locale(parts[0], parts.length > 1 ? parts[1] : '');
        }).toList();
      },
      loading: () => [
        Locale(
          AppLangVersionUtils.getLocaleLang(),
          AppLangVersionUtils.getLocaleCountry(),
        ),
      ],
      error: (_, stackTrace) => [
        Locale(
          AppLangVersionUtils.getLocaleLang(),
          AppLangVersionUtils.getLocaleCountry(),
        ),
      ],
    );

    return PopScope(
      canPop: true,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Xo',
        locale: locale,
        scaffoldMessengerKey: ToastUtil.scaffoldMessengerKey,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        navigatorKey: navigatorKey,
        supportedLocales: supportedLocales,
        themeMode: theme.themeMode,
        theme: theme.toThemeData(),
        darkTheme: theme.toThemeData(),
        navigatorObservers: [appRouteObserver],
        home: const SplashPage(),
        onGenerateRoute: generateDeferredRoute,
      ),
    );
  }
}
