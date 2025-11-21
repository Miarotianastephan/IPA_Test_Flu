import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/l10n/app_localizations.dart';
import '../../provider/api_provider.dart';
import '../../utils/toast_util.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => ChangePasswordPageState();
}

class ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _checkPasswordController =
      TextEditingController();

  bool _obscurePassword = true;

  Future<void> _bind(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;

    final oldPassword = _oldPasswordController.text;
    final newPassword = _newPasswordController.text;
    final checkPassword = _checkPasswordController.text;

    if (oldPassword.isEmpty) {
      ToastUtil.warning(localizations.enterOldPassword);
      return;
    }

    if (newPassword.isEmpty) {
      ToastUtil.warning(localizations.enterNewPassword);
      return;
    }

    if (checkPassword.isEmpty) {
      ToastUtil.warning(localizations.enterConfirmPassword);
      return;
    }

    if (oldPassword.length < 6 ||
        newPassword.length < 6 ||
        checkPassword.length < 6) {
      ToastUtil.warning(localizations.passwordTooShort);
      return;
    }

    if (checkPassword != newPassword) {
      ToastUtil.warning(localizations.passwordMismatch);
      return;
    }

    final userService = ref.read(userServiceProvider);
    final navigator = Navigator.of(context);

    try {
      await userService.updatePassword(newPassword, oldPassword);
      ToastUtil.success(localizations.passwordUpdateSuccess);
      if (!mounted) return;
      navigator.pop();
    } catch (err, stack) {
      debugPrint("Error updating password: $err");
      debugPrintStack(stackTrace: stack);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: const Text(""), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.bindPassword,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),

            // 密码输入
            TextField(
              controller: _oldPasswordController,
              obscureText: _obscurePassword,
              cursorColor: theme.colorScheme.onSurface,
              decoration: InputDecoration(
                labelText: localizations.oldPassword,
                labelStyle: TextStyle(
                  color: theme.colorScheme.onSurface, // 未聚焦状态 labelText 颜色
                ),
                floatingLabelStyle: TextStyle(
                  color: theme.colorScheme.onSurface, // 聚焦时 labelText 颜色
                ),
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
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
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              obscureText: _obscurePassword,
              cursorColor: theme.colorScheme.onSurface,
              decoration: InputDecoration(
                labelText: localizations.newPassword,
                labelStyle: TextStyle(
                  color: theme.colorScheme.onSurface, // 未聚焦状态 labelText 颜色
                ),
                floatingLabelStyle: TextStyle(
                  color: theme.colorScheme.onSurface, // 聚焦时 labelText 颜色
                ),
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
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
            const SizedBox(height: 16),
            TextField(
              controller: _checkPasswordController,
              obscureText: _obscurePassword,
              cursorColor: theme.colorScheme.onSurface,
              decoration: InputDecoration(
                labelText: localizations.confirmPassword,
                labelStyle: TextStyle(
                  color: theme.colorScheme.onSurface, // 未聚焦状态 labelText 颜色
                ),
                floatingLabelStyle: TextStyle(
                  color: theme.colorScheme.onSurface, // 聚焦时 labelText 颜色
                ),
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
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
              onPressed: () {
                _bind(context);
              },
              child: Text(localizations.bind, style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
