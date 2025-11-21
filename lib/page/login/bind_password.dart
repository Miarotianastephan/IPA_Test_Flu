import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/l10n/app_localizations.dart';
import '../../provider/api_provider.dart';
import '../../utils/toast_util.dart';

class BindPasswordPage extends ConsumerStatefulWidget {
  const BindPasswordPage({super.key});

  @override
  ConsumerState<BindPasswordPage> createState() => _BindPasswordPageState();
}

class _BindPasswordPageState extends ConsumerState<BindPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _checkPasswordController =
      TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool _obscurePassword = true;

  Future<void> _bind(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    final password = _passwordController.text;
    final checkPassword = _checkPasswordController.text;
    final username = _usernameController.text;

    if (password.isEmpty || checkPassword.isEmpty) {
      ToastUtil.warning(localizations.enterPassword);
      return;
    }

    if (username.isEmpty) {
      ToastUtil.warning(localizations.enterUsername);
      return;
    }

    if (password.length < 6 || checkPassword.length < 6) {
      ToastUtil.warning(localizations.passwordTooShort);
      return;
    }

    if (password != checkPassword) {
      ToastUtil.warning(localizations.passwordMismatch);
      return;
    }

    final userService = ref.read(userServiceProvider);
    final navigator = Navigator.of(context);

    try {
      await userService.bindPassword(username, password);
      ToastUtil.success(localizations.bindSuccess);
      navigator.pop(); // 返回上一个页面
    } catch (err, stack) {
      debugPrint("登录出错: $err");
      debugPrintStack(stackTrace: stack);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

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
            // 账号输入
            TextField(
              controller: _usernameController,
              cursorColor: theme.colorScheme.onSurface,
              decoration: InputDecoration(
                labelStyle: TextStyle(
                  color: theme.colorScheme.onSurface, // 未聚焦状态 labelText 颜色
                ),
                floatingLabelStyle: TextStyle(
                  color: theme.colorScheme.onSurface, // 聚焦时 labelText 颜色
                ),
                labelText: localizations.usernameOrEmail,
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
            const SizedBox(height: 16),

            // 密码输入
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              cursorColor: theme.colorScheme.onSurface,
              decoration: InputDecoration(
                labelText: localizations.password,
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
            // 密码输入
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
