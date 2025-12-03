import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/services/app_service.dart';
import '../config/storage_config.dart';
import 'api_provider.dart';

/// AppConfig 的状态：
/// - data: 配置数据
/// - loading: 是否正在加载
/// - error: 错误信息
class AppConfigState {
  final Map<String, dynamic>? data;
  final bool loading;
  final String? error;

  const AppConfigState({
    this.data,
    this.loading = false,
    this.error,
  });

  AppConfigState copyWith({
    Map<String, dynamic>? data,
    bool? loading,
    String? error,
  }) {
    return AppConfigState(
      data: data ?? this.data,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

/// 管理 AppConfig 的 Notifier
class AppConfigNotifier extends StateNotifier<AppConfigState> {
  final AppService appService;

  AppConfigNotifier(this.appService) : super(const AppConfigState()) {
    _loadFromStorage();
  }

  /// 先读本地缓存
  void _loadFromStorage() {
    final raw = StorageService.instance.getValue("app_config");
    if (raw != null) {
      try {
        final map = raw is String ? jsonDecode(raw) : Map<String, dynamic>.from(raw as Map);
        state = state.copyWith(data: map);
      } catch (_) {}
    }
  }

  /// 外部调用：从 API 加载配置
  Future<void> loadConfig() async {
    try {
      state = state.copyWith(loading: true);

      final resp = await appService.appConfig();
      final config = resp.data;

      // 更新状态
      state = state.copyWith(data: config, loading: false);

      // 持久化本地
      if (config != null) {
        await StorageService.instance.setValue(
          "app_config",
          jsonEncode(config),
        );
      }
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.toString(),
      );
    }
  }
}

/// Provider 暴露给全局使用
final appConfigProvider =
StateNotifierProvider<AppConfigNotifier, AppConfigState>((ref) {
  final appService = ref.watch(appServiceProvider);
  return AppConfigNotifier(appService);
});