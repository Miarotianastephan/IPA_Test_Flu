import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/first_open.dart';
import 'package:live_app/provider/my_user_provider.dart';
import 'package:live_app/utils/device_info_helper.dart';

import '../config/storage_config.dart';
import '../database/app_database.dart';
import '../models/api_response.dart';
import '../models/userinfo.dart';
import '../provider/api_provider.dart';
import '../utils/agent_tracking.dart';
import 'currency_provider.dart';
import 'wallet_provider.dart';
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
    final persistedUser = UserInfo.fromJson(map);
    final persistedToken = StorageService.instance.userToken;
    state =
        (persistedToken != null &&
            (persistedUser.token == null || persistedUser.token!.isEmpty))
        ? persistedUser.copyWith(token: persistedToken)
        : persistedUser;

    // 同步 webSœocket 连接状态
    _syncWebSocket();
  }

  UserInfo _mergeSessionFields(UserInfo user) {
    final current = state;
    final currentToken = current?.token;
    final currentCredential = current?.credential;
    final nextToken = user.token;

    return user.copyWith(
      token: (nextToken != null && nextToken.isNotEmpty)
          ? nextToken
          : currentToken,
      credential: user.credential ?? currentCredential,
    );
  }

  // 保存用户信息
  Future<void> _saveToStorage(UserInfo user) async {
    StorageService.instance.setValue("user_info", jsonEncode(user));
    final token = user.token;
    if (token != null && token.isNotEmpty) {
      StorageService.instance.setValue("token", token);
    }
  }

  void setUser(UserInfo user) {
    final mergedUser = _mergeSessionFields(user);
    state = mergedUser;
    ref.read(userProvider.notifier).setUser(mergedUser);
    _syncWebSocket();
  }

  Future<void> syncUser(UserInfo user) async {
    final mergedUser = _mergeSessionFields(user);
    state = mergedUser;
    ref.read(userProvider.notifier).setUser(mergedUser);
    await _saveToStorage(mergedUser);
    _syncWebSocket();
  }

  Future<UserInfo?> refreshUserInfo() async {
    final userService = ref.read(userServiceProvider);

    try {
      final res = await userService.getInfo();
      final data = res.data;
      if (data != null) {
        await syncUser(data);
      }
      return data;
    } catch (e) {
      debugPrint("刷新当前用户信息失败：$e");
      return null;
    }
  }

  void loadWalletData() {
    Future.microtask(() {
      ref.read(walletProvider.notifier).loadBalance();
    });
  }

  void loadCurrencyData() {
    Future.microtask(() {
      ref.read(currencyProvider.notifier).fetchCurrencyInfo();
    });
  }

  // 常见操作：刷新 Token
  Future<ApiResponse<UserInfo>?> refreshToken() async {
    final userService = ref.read(userServiceProvider);

    try {
      final res = await userService.refreshToken();
      final data = res.data;
      if (data != null) {
        state = data;
        ref.read(userProvider.notifier).setUser(data);
        await _saveToStorage(data);
        _syncWebSocket();
      }
      return res;
    } catch (e) {
      debugPrint("刷新 token 失败：$e");
      rethrow;
    }
  }

  // 登录（用户名密码）
  Future<ApiResponse<UserInfo>?> login(String username, String password) async {
    final userService = ref.read(userServiceProvider);

    try {
      final res = await userService.login(username, password);

      if (res.data != null) {
        state = res.data;
        ref.read(userProvider.notifier).setUser(res.data!);
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
        ref.read(userProvider.notifier).setUser(res.data!);
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
      final trackingQueryParams = AgentTracking.getStoredTrackingQueryParams();
      final agentCode = AgentTracking.getStoredAgentCode();
      final res = await userService.visitorLogin(
        idFirstOpen,
        userid: userid,
        code: agentCode,
        trackingQueryParams: trackingQueryParams,
      );
      if (res.data != null) {
        state = res.data;
        ref.read(userProvider.notifier).setUser(res.data!);
        await _saveToStorage(res.data!);
        _syncWebSocket();
      }
      return res;
    } catch (e) {
      debugPrint("游客登录失败：$e");
      rethrow;
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
    } catch (e) {
      rethrow;
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

final currentUserIdProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.id;
});

final currentUserDatabaseProvider = Provider<AppDatabase>((ref) {
  final userId = ref.watch(currentUserIdProvider);

  final db = AppDatabase.instance(userId: userId);
  ref.onDispose(() {
    AppDatabase.removeInstance(userId);
  });
  return db;
});
