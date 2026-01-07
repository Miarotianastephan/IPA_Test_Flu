import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/firebase_options.dart';
import 'package:live_app/page/splash_page.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/provider/message_dispatcher_provider.dart';
import 'package:live_app/utils/platform_check.dart';
import 'package:live_app/utils/route_utils.dart';

import 'api/services/notification_service.dart';
import 'config/storage_config.dart';
import 'provider/locale_provider.dart';
import 'provider/theme_provider.dart';
import 'utils/toast_util.dart';
import 'utils/window_manager_wrapper.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    await Firebase.initializeApp();
  }
  await dotenv.load(fileName: ".env");
  if (!kIsWeb) await NotificationService.instance.init();
  await initWindowManager();
  if (!kIsWeb) await PlatformCheck.initMediaKitIfHuawei();
  await StorageService.instance.init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(currentThemeProvider);
    final locale = ref.watch(localeProvider);
    final availableLanguagesAsync = ref.watch(availableLanguagesProvider);

    ref.watch(globalInitializerProvider);
    ref.watch(initializeLocaleProvider);

    final supportedLocales = availableLanguagesAsync.when(
      data: (languages) {
        if (languages.isEmpty) {
          return const [Locale('en', 'US')];
        }
        return languages.map((lang) {
          final parts = lang.languageCode.split('_');
          return Locale(parts[0], parts.length > 1 ? parts[1] : '');
        }).toList();
      },
      loading: () => const [Locale('en', 'US')],
      error: (_, __) => const [Locale('en', 'US')],
    );

    return MaterialApp(
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
      home: const SplashPage(),
      routes: appRoutes,
    );
  }
}
