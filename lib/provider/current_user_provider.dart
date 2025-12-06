import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/first_open.dart';
import 'package:live_app/utils/device_info_helper.dart';

import '../config/storage_config.dart';
import '../database/app_database.dart';
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
    if (state != null) return;

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

  void setUser(UserInfo user) {
    state = user;
    _syncWebSocket();
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
  Future<ApiResponse<UserInfo>?> visitorLogin(
    int idFirstOpen, [
    String? userid,
  ]) async {
    final userService = ref.read(userServiceProvider);
    try {
      final res = await userService.visitorLogin(idFirstOpen, userid: userid);
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
  Future<void> logout({bool cleanCache = false}) async {
    final userId = state?.id;

    state = null;
    await StorageService.instance.remove("user_info");
    await StorageService.instance.remove("token");

    // 断开 WebSocket
    ref.read(webSocketProvider.notifier).disconnect();

    if (cleanCache && userId != null) {
      await StorageService.instance.deleteDatabaseForUser(userId);
    }
    final res = await recordFirstOpen();
    final visitorRes = await visitorLogin(
      res!.data!.idFirstOpen!,
      res.data?.userId,
    );
    if (visitorRes?.data != null) {
      state = visitorRes!.data;
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

  // 同步 WebSocket 状态（用户切换 / 刷新 / 登录后自动保持连接）
  void _syncWebSocket() {
    final ws = ref.read(webSocketProvider.notifier);

    if (state == null) {
      ws.disconnect();
    } else {
      debugPrint(
        "[WS Sync] User found (isVisitor: ${state!.isVisitor}) -> connecting...",
      );
      ws.connect(state!);
    }
  }
}

// Provider
final currentUserProvider =
    StateNotifierProvider<CurrentUserNotifier, UserInfo?>((ref) {
      return CurrentUserNotifier(ref);
    });

final currentUserIdProvider = Provider<int?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.id;
});

final currentUserDatabaseProvider = Provider<AppDatabase>((ref) {
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) {
    throw Exception("No user logged in - cannot access database");
  }

  final db = AppDatabase(userId: userId);
  ref.onDispose(db.close);
  return db;
});
