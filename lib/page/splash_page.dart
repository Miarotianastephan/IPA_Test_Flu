// splash_page.dart
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_app/models/first_open.dart';
import 'package:live_app/page/maintenance_page.dart';
import 'package:live_app/provider/app_config_provider.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/utils/icon_utils.dart';
import 'package:live_app/widgets/encrypted_image.dart';
import 'package:live_app/widgets/image_sequence_player.dart';
import 'package:live_app/widgets/loading_dots.dart';

import '../api/services/user_service.dart';
import '../config/storage_config.dart';
import '../models/api_response.dart';
import '../models/userinfo.dart';
import '../provider/api_provider.dart';
import '../provider/current_user_provider.dart';
import '../utils/device_info_helper.dart';
import 'home.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  double _opacity = 1.0;
  String? _i18nStatus;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _init() async {
    final userService = ref.read(userServiceProvider);

    ApiResponse<UserInfo>? userInfo;

    try {
      final token = StorageService.instance.getValue("token");

      if (token != null) {
        // 已有 token，尝试刷新
        userInfo = await userService.refreshToken();
      } else {
        // 没有 token，走游客登录
        final res = await recordFirstOpen();

        userInfo = await visitorLogin(
          userService,
          res!.data!.idFirstOpen!,
          res.data?.userId,
        );
      }
    } catch (err) {
      debugPrint("刷新 token 失败，尝试游客模式: $err");
      final res = await recordFirstOpen();
      if (res != null && res.success && res.data != null) {
        userInfo = await visitorLogin(
          userService,
          res.data!.idFirstOpen!,
          res.data!.userId,
        );
      }
    }

    if (userInfo != null) {
      await saveUserInfoWithToken(userInfo);
      if (userInfo.data != null) {
        ref.read(currentUserProvider.notifier).setUser(userInfo.data!);
      }
    }
    await getAppConfig();

    try {
      setState(() {
        _i18nStatus = 'Downloading translations...';
      });
      await ref.read(i18nNotifierProvider.notifier).initialize();
      setState(() {
        _i18nStatus = 'Translations loaded';
      });
    } catch (e, st) {
      debugPrintStack(stackTrace: st);
      setState(() {
        _i18nStatus = 'Error loading translations';
      });
    }
  }

  Future<void> saveUserInfoWithToken(ApiResponse<UserInfo> userInfo) async {
    await StorageService.instance.clearUserData();
    await StorageService.instance.setValue("token", userInfo.data?.token);
    await StorageService.instance.setValue(
      "user_info",
      jsonEncode(userInfo.data),
    );
    final jsonString = StorageService.instance.getValue("user_info");
    if (jsonString == null || jsonString.isEmpty) {
      throw Exception("");
    }
  }

  Future<ApiResponse<UserInfo>?> visitorLogin(
    UserService userService,
    int idFirstOpen, [
    String? userid,
  ]) async {
    try {
      return await userService.visitorLogin(idFirstOpen, userid: userid);
    } catch (e, st) {
      debugPrint("游客登录失败: $e");
      debugPrintStack(stackTrace: st);
      return null; // 返回 null，应用继续运行
    }
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
          navigateTo(HomePage(config: appConfig.data));
        }
      }
    } catch (e, st) {
      debugPrintStack(stackTrace: st);
    }
  }

  Future<ApiResponse<FirstOpen>?> recordFirstOpen() async {
    try {
      final deviceData = await DeviceInfoHelper.instance.getFirstOpenData();

      final userService = ref.read(userServiceProvider);
      final apiResponse = await userService.firstOpen(deviceData);

      return apiResponse;
    } catch (e, st) {
      debugPrint('[FirstOpen] ✗ Error: $e');
      debugPrintStack(stackTrace: st);
      return null;
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
      } catch (e) {
        debugPrint("初始化失败: $e");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = constraints.maxHeight;
          final screenWidth = constraints.maxWidth;

          return AnimatedOpacity(
            opacity: _opacity,
            duration: const Duration(milliseconds: 500),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Stack(
                        children: [
                          SizedBox(
                            height: screenHeight * 0.8,
                            width: screenWidth,
                            child: ImageSequencePlayer(
                              directory: "lib/assets/splash_animation/",
                              prefix: "seq_0_",
                              frameCount: 60,
                              fps: 30,
                              loop: true,
                            ),
                          ),
                          Positioned.fill(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 0.5,
                                sigmaY: 0.5,
                              ),
                              child: Container(
                                color: Colors.black.withValues(alpha: 0.2),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: screenHeight * 0.08,
                            child: ClipRect(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color.fromARGB(255, 0, 0, 0),
                                        Colors.transparent,
                                      ],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(76, 93, 0, 255),
                              Color.fromARGB(77, 0, 67, 182),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      Container(
                        height: screenHeight * 0.2,
                        width: double.infinity,
                        color: Colors.black,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            EncryptedImage(
                              url:
                                  ref
                                      .read(appConfigProvider)
                                      .data?["favicon_url"] ??
                                  "",
                              height: screenHeight * 0.04,
                              errorWidget: Image.asset(
                                "lib/assets/logo.jpg",
                                height: screenHeight * 0.04,
                              ),
                            ),
                            const LoadingDots(),
                            if (_i18nStatus != null) ...[
                              Text(
                                _i18nStatus!,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Watch\nEarn\nLive\nMore',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.croissantOne(
                          textStyle: const TextStyle(
                            fontSize: 50,
                            color: Colors.white,
                            height: 0.9,
                            letterSpacing: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
