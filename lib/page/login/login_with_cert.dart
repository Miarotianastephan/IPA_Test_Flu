import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/l10n/app_localizations.dart';

import '../../provider/api_provider.dart';
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
    final localizations = AppLocalizations.of(context)!;
    final code = _qrCodeController.text;
    if (code.isEmpty) {
      ToastUtil.warning(localizations.enterCredentialKey);
      return;
    }

    final userService = ref.read(userServiceProvider);

    try {
      await userService.loginByCredential(code);
      ToastUtil.success(localizations.loginSuccess);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
            (route) => false, // false 表示移除所有旧页面
          );
        }
      });
    } catch (err, stack) {
      debugPrint("登录出错: $err");
      debugPrintStack(stackTrace: stack);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      appBar: AppBar(title: const Text(""), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.loginWithCredential,
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
                labelText: localizations.credentialKey,
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
              child: Text(
                AppLocalizations.of(context)!.login,
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
