import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/config/storage_config.dart';
import 'package:live_app/models/api_response.dart';
import 'package:live_app/models/userinfo.dart';
import 'package:live_app/page/login/login_with_cert.dart';
import 'package:live_app/page/login/login_with_qrcode.dart';
import 'package:live_app/provider/api_provider.dart';
import 'package:live_app/provider/i18n_provider.dart';

import '../../provider/current_user_provider.dart';
import '../../utils/toast_util.dart';
import '../home.dart';

class LoginWithUsernamePage extends ConsumerStatefulWidget {
  const LoginWithUsernamePage({super.key});

  @override
  ConsumerState<LoginWithUsernamePage> createState() =>
      _LoginWithUsernamePageState();
}

class _LoginWithUsernamePageState extends ConsumerState<LoginWithUsernamePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  ApiResponse<UserInfo>? userInfo;

  bool _isLoading = false;

  Future<void> _login(BuildContext context) async {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ToastUtil.warning(translate("enterUsernameAndPassword"));
      return;
    }

    if (password.length < 6) {
      ToastUtil.warning(translate("passwordTooShort"));
      return;
    }

    setState(() {
      _isLoading = true;
    });
    final currentUserNotifier = ref.read(currentUserProvider.notifier);

    try {
      final res = await currentUserNotifier.login(username, password);

      if (res?.data != null) {
        ToastUtil.success(translate("loginSuccess"));
        getAppConfig();

        if (!mounted) return;
      } else {
        ToastUtil.warning(translate("loginFailed"));
      }
    } catch (err, stack) {
      debugPrint("登录失败: $err");
      debugPrintStack(stackTrace: stack);
      setState(() {
        _isLoading = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> getAppConfig() async {
    final appService = ref.read(appServiceProvider);
    final navigator = Navigator.of(context);
    try {
      final appConfig = await appService.appConfig();

      await StorageService.instance.setValue(
        "app_config",
        jsonEncode(appConfig.data),
      );

      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => HomePage(config: appConfig.data)),
        (route) => false,
      );
    } catch (e, st) {
      debugPrintStack(stackTrace: st);
    }
  }

  Future<void> saveUserInfoWithToken(ApiResponse<UserInfo> userInfo) async {
    await StorageService.instance.clearUserData();
    await StorageService.instance.setValue("token", userInfo.data?.token);
    await StorageService.instance.setValue(
      "user_info",
      jsonEncode(userInfo.data),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text(""), centerTitle: true),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        translate("welcomeLogin"),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // 账号输入
                      TextField(
                        controller: _usernameController,
                        cursorColor: theme.colorScheme.onSurface,
                        decoration: InputDecoration(
                          labelStyle: TextStyle(
                            color: theme.colorScheme.onSurface,
                          ),
                          floatingLabelStyle: TextStyle(
                            color: theme.colorScheme.onSurface,
                          ),
                          labelText: translate("usernameOrEmail"),
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 密码输入
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        cursorColor: theme.colorScheme.onSurface,
                        decoration: InputDecoration(
                          labelText: translate("password"),
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // 登录按钮
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.onSecondary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => _login(context),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                translate("login"),
                                style: const TextStyle(fontSize: 18),
                              ),
                      ),
                      const SizedBox(height: 24),

                      // 第三方登录
                      Center(
                        child: Column(
                          children: [
                            Text(translate("otherLoginMethods")),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => LoginWithQrcodePage(),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.qr_code,
                                        size: 36,
                                        color: Colors.green,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        translate("loginWithQrcode"),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 24),
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => LoginWithCertPage(),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.key_outlined,
                                        size: 36,
                                        color: Colors.blueAccent,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        translate("loginWithCredential"),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Center(
                  child: Text.rich(
                    TextSpan(
                      text: translate("agreeTo"),
                      children: [
                        TextSpan(
                          text: translate("userAgreement"),
                          style: TextStyle(color: theme.colorScheme.onPrimary),
                        ),
                        TextSpan(text: translate("and")),
                        TextSpan(
                          text: translate("privacyPolicy"),
                          style: TextStyle(color: theme.colorScheme.onPrimary),
                        ),
                      ],
                    ),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
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
