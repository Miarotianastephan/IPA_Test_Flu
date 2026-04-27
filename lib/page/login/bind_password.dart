import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/config/storage_config.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/utils/username_formatter.dart';
import 'package:live_app/widgets/html_text_field.dart';
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
  final TextEditingController _nicknameController = TextEditingController();
  bool _obscurePassword = true;

  Future<void> _bind(BuildContext context) async {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    final password = _passwordController.text;
    final checkPassword = _checkPasswordController.text;
    final username = _usernameController.text;
    final nickname = _nicknameController.text;

    if (password.isEmpty || checkPassword.isEmpty) {
      ToastUtil.warning(i18n.translate('enterPassword'));
      return;
    }

    if (username.isEmpty) {
      ToastUtil.warning(i18n.translate('enterUsername'));
      return;
    }

    if (password.length < 6 || checkPassword.length < 6) {
      ToastUtil.warning(i18n.translate('passwordTooShort'));
      return;
    }

    if (password != checkPassword) {
      ToastUtil.warning(i18n.translate('passwordMismatch'));
      return;
    }

    final userService = ref.read(userServiceProvider);
    final navigator = Navigator.of(context);

    try {
      final token = await StorageService.instance.getValue("token");
      debugPrint("Token : $token");
      await userService.bindPassword(username, nickname, password);
      ToastUtil.success(i18n.translate('bindSuccess'));
      navigator.pop();
    } catch (err) {
      final msg = err.toString();
      if (msg.contains("User already has a bound password")) {
        ToastUtil.warning("Already Has Password");
      } else {
        ToastUtil.warning(i18n.translate('serverError'));
      }
      debugPrint("登录出错: $err");
    }
  }

  @override
  Widget build(BuildContext context) {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text(""), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                i18n.translate('bindPassword'),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              // 账号输入
              HtmlTextField(
                controller: _usernameController,
                inputFormatters: [UsernameFormatter()],
                cursorColor: theme.colorScheme.onSurface,
                decoration: InputDecoration(
                  labelStyle: TextStyle(
                    color: theme.colorScheme.onSurface, // 未聚焦状态 labelText 颜色
                  ),
                  floatingLabelStyle: TextStyle(
                    color: theme.colorScheme.onSurface, // 聚焦时 labelText 颜色
                  ),
                  labelText: i18n.translate('usernameOrEmail'),
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
              // 账号输入
              HtmlTextField(
                controller: _nicknameController,
                cursorColor: theme.colorScheme.onSurface,
                decoration: InputDecoration(
                  labelStyle: TextStyle(
                    color: theme.colorScheme.onSurface, // 未聚焦状态 labelText 颜色
                  ),
                  floatingLabelStyle: TextStyle(
                    color: theme.colorScheme.onSurface, // 聚焦时 labelText 颜色
                  ),
                  labelText: i18n.translate('nickname'),
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
              HtmlTextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                cursorColor: theme.colorScheme.onSurface,
                decoration: InputDecoration(
                  labelText: i18n.translate('password'),
                  labelStyle: TextStyle(
                    color: theme.colorScheme.onSurface, // 未聚焦状态 labelText 颜色
                  ),
                  floatingLabelStyle: TextStyle(
                    color: theme.colorScheme.onSurface, // 聚焦时 labelText 颜色
                  ),
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
              HtmlTextField(
                controller: _checkPasswordController,
                obscureText: _obscurePassword,
                cursorColor: theme.colorScheme.onSurface,
                decoration: InputDecoration(
                  labelText: i18n.translate('confirmPassword'),
                  labelStyle: TextStyle(
                    color: theme.colorScheme.onSurface, // 未聚焦状态 labelText 颜色
                  ),
                  floatingLabelStyle: TextStyle(
                    color: theme.colorScheme.onSurface, // 聚焦时 labelText 颜色
                  ),
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
                child: Text(
                  i18n.translate('bind'),
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
