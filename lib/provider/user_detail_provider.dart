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

  UserDetailState copyWith({UserInfo? user, bool? loading, String? error}) {
    return UserDetailState(
      user: user ?? this.user,
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }
}

/// 用户详情状态管理器
class UserDetailNotifier extends StateNotifier<UserDetailState> {
  final Ref ref;

  UserDetailNotifier(this.ref) : super(UserDetailState());

  /// 加载用户详情
  Future<void> loadUserDetail(int userId) async {
    state = state.copyWith(loading: true, error: null);

    try {
      final userService = ref.read(userServiceProvider);
      final res = await userService.getInfoById(userId);
      final user = res.data;

      state = state.copyWith(user: user);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(loading: false);
    }
  }

  /// 关注 / 取消关注
  Future<void> toggleFollow() async {
    final user = state.user;
    if (user == null) return;

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

/// 用户详情 Provider
final userDetailProvider =
    StateNotifierProvider.family<UserDetailNotifier, UserDetailState, int>((
      ref,
      userId,
    ) {
      final notifier = UserDetailNotifier(ref);
      // 可选：初始化时立即加载用户信息
      notifier.loadUserDetail(userId);
      return notifier;
    });
