import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/api_provider.dart';

class FollowState {
  final bool isFollowed;
  final int fansCount; // Followers
  final int followCount; // How many this user follows

  FollowState({
    required this.isFollowed,
    required this.fansCount,
    required this.followCount,
  });

  FollowState copyWith({bool? isFollowed, int? fansCount, int? followCount}) {
    return FollowState(
      isFollowed: isFollowed ?? this.isFollowed,
      fansCount: fansCount ?? this.fansCount,
      followCount: followCount ?? this.followCount,
    );
  }

  factory FollowState.initial() =>
      FollowState(isFollowed: false, fansCount: 0, followCount: 0);
}

class UserFollowNotifier extends StateNotifier<FollowState> {
  final Ref ref;
  final String userId;
  bool _isInitialized = false;

  UserFollowNotifier(this.ref, this.userId) : super(FollowState.initial()) {
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    if (_isInitialized) return;

    try {
      final userService = ref.read(userServiceProvider);
      final response = await userService.getInfoById(userId);

      final userData = response.data;
      if (userData != null) {
        _isInitialized = true;
        state = FollowState(
          isFollowed: userData.isFollowed,
          fansCount: userData.fansCount ?? 0,
          followCount: userData.followCount ?? 0,
        );
      }
    } catch (e) {
      print("Error loading initial follow state: $e");
    }
  }

  void setFromBackend({
    required bool isFollowed,
    required int fansCount,
    required int followCount,
  }) {
    _isInitialized = true;
    state = FollowState(
      isFollowed: isFollowed,
      fansCount: fansCount,
      followCount: followCount,
    );
  }

  Future<void> toggleFollow() async {
    final userService = ref.read(userServiceProvider);

    final previousState = state;

    try {
      if (state.isFollowed) {
        state = state.copyWith(
          isFollowed: false,
          fansCount: state.fansCount - 1,
        );

        await userService.unfollow(userId);
      } else {
        state = state.copyWith(
          isFollowed: true,
          fansCount: state.fansCount + 1,
        );

        await userService.follow(userId);
      }
    } catch (e) {
      state = previousState;
      rethrow;
    }
  }
}

final userFollowProvider = StateNotifierProvider.family
    .autoDispose<UserFollowNotifier, FollowState, String>((ref, userId) {
      return UserFollowNotifier(ref, userId);
    });
