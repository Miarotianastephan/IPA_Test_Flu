import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/config/storage_config.dart';
import 'package:live_app/provider/api_provider.dart';
import 'package:live_app/provider/i18n_provider.dart';

import '../../provider/current_user_provider.dart';
import '../../utils/toast_util.dart';
import '../home.dart';

class LoginWithCertPage extends ConsumerStatefulWidget {
  const LoginWithCertPage({super.key});

  @override
  ConsumerState<LoginWithCertPage> createState() => _LoginWithCertPageState();
}

class _LoginWithCertPageState extends ConsumerState<LoginWithCertPage> {
  final TextEditingController _qrCodeController = TextEditingController();

  Future<void> _loginWithQRCode(BuildContext context) async {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);
    final code = _qrCodeController.text.trim();

    if (code.isEmpty) {
      ToastUtil.warning(translate("enterCredentialKey"));
      return;
    }

    final currentUserNotifier = ref.read(currentUserProvider.notifier);

    final res = await currentUserNotifier.loginByCredential(code);

    if (res?.data != null) {
      ToastUtil.success(translate("loginSuccess"));
      getAppConfig();
    } else {
      ToastUtil.warning(translate("loginFailed"));
    }
  }

  Future<void> getAppConfig() async {
    final appService = ref.read(appServiceProvider);

    try {
      final appConfig = await appService.appConfig();

      await StorageService.instance.setValue(
        "app_config",
        jsonEncode(appConfig.data),
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => HomePage(config: appConfig.data),
            ),
            (route) => false,
          );
        }
      });
    } catch (e, st) {
      debugPrintStack(stackTrace: st);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      appBar: AppBar(title: const Text(""), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              translate("loginWithCredential"),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),

            const SizedBox(height: 32),

            // 手动输入二维码
            TextField(
              controller: _qrCodeController,
              cursorColor: theme.colorScheme.onSurface,
              decoration: InputDecoration(
                labelStyle: TextStyle(
                  color: theme.colorScheme.onSurface, // 未聚焦状态 labelText 颜色
                ),
                floatingLabelStyle: TextStyle(
                  color: theme.colorScheme.onSurface, // 聚焦时 labelText 颜色
                ),
                labelText: translate("credentialKey"),
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.onSurface,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.onSurface,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 登录按钮
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                backgroundColor: theme.colorScheme.onSecondary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                _loginWithQRCode(context);
              },
              child: Text(translate("login"), style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
