import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/notif_chinese.dart';
import 'package:live_app/models/userinfo.dart';

import 'api_provider.dart';
import 'current_user_provider.dart';

class UserState {
  final UserInfo? user;
  final bool isLoading;

  const UserState({this.user, this.isLoading = false});

  UserState copyWith({UserInfo? user, bool? isLoading}) {
    return UserState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class UserNotifier extends StateNotifier<UserState> {
  final Ref ref;

  UserNotifier(this.ref) : super(const UserState());
  void setUser(UserInfo user) {
    state = state.copyWith(user: user, isLoading: false);
  }

  void updateUser(UserInfo Function(UserInfo user) update) {
    final currentUser = state.user;
    if (currentUser == null) return;

    state = state.copyWith(user: update(currentUser));
  }

  void updateToken(String token) {
    updateUser((user) => user.copyWith(token: token));
  }

  void clearUser() {
    state = const UserState();
  }

  void setLoading(bool value) {
    state = state.copyWith(isLoading: value);
  }

  Future<bool> buyVip(int vipId) async {
    state = state.copyWith(isLoading: true);
    try {
      final service = ref.read(userServiceProvider);
      final response = await service.buyWithWallet(vipId);
      final data = response.data;
      if (data != null) {
        await ref.read(currentUserProvider.notifier).syncUser(data);
        return true;
      }
      return false;
    } catch (e, stack) {
      debugPrint('Buy VIP Error: $e\n$stack');
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> userInterest({
    required String videoId,
    required int watchDuration,
    required int videoDuration,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final service = ref.read(userServiceProvider);
      final response = await service.userInterest(
        userId: state.user!.id.toString(),
        videoId: videoId,
        watchDuration: watchDuration,
        videoDuration: videoDuration,
      );
      final code = response.code == 1;
      if (code) {
        return true;
      }
      return false;
    } catch (e, stack) {
      debugPrint('User Interest Error: $e\n$stack');
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<({int amount, int forceReload})?> checkUserGiftReceive() async {
    try {
      final service = ref.read(userServiceProvider);
      final response = await service.checkUserGiftReceive();
      return response.data;
    } catch (e, stack) {
      debugPrint('Check User Gift Receive Error: $e\n$stack');
      return null;
    }
  }

  Future<NotifChinese?> getNotifChinese() async {
    try {
      final service = ref.read(userServiceProvider);
      final response = await service.getNotifChinese();
      return response.data;
    } catch (e, stack) {
      debugPrint('Get Notif Chinese Error: $e\n$stack');
      return null;
    }
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier(ref);
});


// final userVip = ref.watch(userProvider).user;
// ref.read(userProvider.notifier).setUser(userInfo);
// ref.read(userProvider.notifier).clearUser();