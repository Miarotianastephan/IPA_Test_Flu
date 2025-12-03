import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/storage_config.dart';
import '../models/api_response.dart';
import '../models/userinfo.dart';
import '../provider/api_provider.dart';
import 'websocket_provider.dart';

class CurrentUserNotifier extends StateNotifier<UserInfo?> {
  final Ref ref;

  CurrentUserNotifier(this.ref) : super(null) {
    _loadFromStorage();
  }

  // 从本地加载用户
  Future<void> _loadFromStorage() async {
    final raw = StorageService.instance.getValue("user_info");
    if (raw == null) return;

    final map = raw is String ? jsonDecode(raw) : raw;
    state = UserInfo.fromJson(map);

    // 同步 webSœocket 连接状态
    _syncWebSocket();
  }

  // 保存用户信息
  Future<void> _saveToStorage(UserInfo user) async {
    StorageService.instance.setValue("user_info", jsonEncode(user));
    StorageService.instance.setValue("token", user.token);
  }

  // 常见操作：刷新 Token
  Future<void> refreshToken() async {
    final userService = ref.read(userServiceProvider);

    try {
      final res = await userService.refreshToken();

      if (res.data != null) {
        state = res.data;
        await _saveToStorage(res.data!);
        _syncWebSocket();
      }
    } catch (e) {
      debugPrint("刷新 token 失败：$e");
    }
  }

  // 登录（用户名密码）
  Future<ApiResponse<UserInfo>?> login(String username, String password) async {
    final userService = ref.read(userServiceProvider);

    try {
      final res = await userService.login(username, password);

      if (res.data != null) {
        state = res.data;
        await _saveToStorage(res.data!);
        _syncWebSocket();
      }

      return res;
    } catch (e) {
      debugPrint("登录失败：$e");
      return null;
    }
  }

  // 凭证登录（二维码 / 密钥）
  Future<ApiResponse<UserInfo>?> loginByCredential(String key) async {
    final userService = ref.read(userServiceProvider);

    try {
      final res = await userService.loginByCredential(key);

      if (res.data != null) {
        state = res.data;
        await _saveToStorage(res.data!);
        _syncWebSocket();
      }

      return res;
    } catch (e) {
      debugPrint("凭证登录失败：$e");
      return null;
    }
  }

  // 游客登录
  Future<ApiResponse<UserInfo>?> visitorLogin() async {
    final userService = ref.read(userServiceProvider);

    try {
      final res = await userService.visitorLogin();
      if (res.data != null) {
        state = res.data;
        await _saveToStorage(res.data!);
        _syncWebSocket();
      }
      return res;
    } catch (e) {
      debugPrint("游客登录失败：$e");
      return null;
    }
  }

  // 退出登录
  void logout() {
    state = null;
    StorageService.instance.remove("user_info");
    StorageService.instance.remove("token");

    // 断开 WebSocket
    ref.read(webSocketProvider.notifier).disconnect();
  }

  // 同步 WebSocket 状态（用户切换 / 刷新 / 登录后自动保持连接）
  void _syncWebSocket() {
    final ws = ref.read(webSocketProvider.notifier);

    if (state == null) {
      // 🔌 Aucun user -> déconnexion WS
      ws.disconnect();
    } else if (state!.isVisitor) {
      // 👤 Visiteur -> pas de connexion WebSocket
      ws.disconnect();
      debugPrint("👤 Visitor mode: WebSocket disabled");
    } else {
      // 🔗 Connexion WS avec l'utilisateur authentifié
      ws.connect(state!);
    }
  }
}

// Provider
final currentUserProvider =
    StateNotifierProvider<CurrentUserNotifier, UserInfo?>((ref) {
      return CurrentUserNotifier(ref);
    });
