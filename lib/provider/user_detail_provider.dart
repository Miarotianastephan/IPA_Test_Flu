import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/userinfo.dart';
import 'api_provider.dart';

/// 用户详情状态
class UserDetailState {
  final UserInfo? user;
  final bool loading;
  final String? error;

  UserDetailState({this.user, this.loading = false, this.error});

  UserDetailState copyWith({
    UserInfo? user,
    bool? loading,
    String? error,
    bool clearError = false,
  }) {
    return UserDetailState(
      user: user ?? this.user,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// 用户详情状态管理器
class UserDetailNotifier extends StateNotifier<UserDetailState> {
  final Ref ref;

  UserDetailNotifier(this.ref, {UserInfo? initialUser})
    : super(UserDetailState(user: initialUser));

  /// 初始化用户信息
  void initUser(UserInfo user) {
    state = UserDetailState(user: user);
  }

  /// 加载用户详情
  Future<UserInfo?> loadUserDetail(int userId) async {
    state = state.copyWith(loading: true, clearError: true);

    try {
      final userService = ref.read(userServiceProvider);
      final res = await userService.getInfoById(userId);
      final user = res.data;

      state = state.copyWith(user: user, loading: false);
      return user;
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
      return null;
    }
  }

  /// 关注 / 取消关注
  Future<void> toggleFollow() async {
    final user = state.user;
    if (user == null) {
      return;
    }

    final userService = ref.read(userServiceProvider);
    final isCurrentlyFollowed = user.isFollowed;
    final newValue = !isCurrentlyFollowed;

    try {
      // 根据当前关注状态调用正确的接口
      if (isCurrentlyFollowed) {
        await userService.unfollow(user.id);
      } else {
        await userService.follow(user.id);
      }

      // 更新当前用户信息
      state = state.copyWith(user: user.copyWith(isFollowed: newValue));
    } catch (e) {
      debugPrint('关注失败: $e');
    }
  }
}

/// 用户详情 Provider 参数
class UserDetailProviderParam {
  final int userId;
  final UserInfo? initialUser;
  // 使用唯一的实例 ID，确保每个页面实例都有自己的 provider
  final String instanceId;

  UserDetailProviderParam(this.userId, {this.initialUser})
    : instanceId = '${userId}_${DateTime.now().microsecondsSinceEpoch}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserDetailProviderParam &&
          runtimeType == other.runtimeType &&
          instanceId == other.instanceId;

  @override
  int get hashCode => instanceId.hashCode;
}

/// 用户详情 Provider
final userDetailProvider =
    StateNotifierProvider.family<
      UserDetailNotifier,
      UserDetailState,
      UserDetailProviderParam
    >((ref, param) {
      final notifier = UserDetailNotifier(ref, initialUser: param.initialUser);
      return notifier;
    });
