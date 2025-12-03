import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/page/splash_page.dart';
import 'package:live_app/provider/message_dispatcher_provider.dart';
import 'package:live_app/utils/route_utils.dart';
import 'package:media_kit/media_kit.dart';

import 'api/services/notification_service.dart';
import 'config/storage_config.dart';
import 'l10n/app_localizations.dart';
import 'provider/locale_provider.dart';
import 'provider/theme_provider.dart';
import 'utils/toast_util.dart';
import 'utils/window_manager_wrapper.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");
  final notificationService = NotificationService();
  await notificationService.init();
  MediaKit.ensureInitialized();
  await initWindowManager();
  await StorageService.instance.init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(currentThemeProvider);
    final locale = ref.watch(localeProvider);
    ref.watch(globalInitializerProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Xo',
      locale: locale,
      scaffoldMessengerKey: ToastUtil.scaffoldMessengerKey,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      navigatorKey: navigatorKey,
      supportedLocales: AppLocalizations.supportedLocales,
      themeMode: theme.themeMode,
      theme: theme.toThemeData(),
      darkTheme: theme.toThemeData(),
      home: const SplashPage(),
      routes: appRoutes,
    );
  }
}
