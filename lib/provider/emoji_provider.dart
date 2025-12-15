import 'package:flutter/foundation.dart';
import 'package:live_app/api/services/user_service.dart';
import 'package:live_app/models/emoji.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/page_params.dart';
import 'package:live_app/provider/api_provider.dart';

class EmojiState {
  final List<Emoji> emojis;
  final bool isLoading;
  final bool hasMore;
  final int page;
  final int type;
  final String? error;

  EmojiState({
    required this.emojis,
    required this.isLoading,
    required this.hasMore,
    required this.page,
    required this.type,
    this.error,
  });

  factory EmojiState.initial({int type = 1}) {
    return EmojiState(
      emojis: [],
      isLoading: false,
      hasMore: true,
      page: 1,
      type: type,
    );
  }

  EmojiState copyWith({
    List<Emoji>? emojis,
    bool? isLoading,
    bool? hasMore,
    int? page,
    int? type,
    String? error,
  }) {
    return EmojiState(
      emojis: emojis ?? this.emojis,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      type: type ?? this.type,
      error: error,
    );
  }
}

class EmojiNotifier extends StateNotifier<EmojiState> {
  final UserService _userService;
  final int type;
  //TYPE 1: emoji, 2: gif

  EmojiNotifier(this._userService, this.type)
      : super(EmojiState.initial(type: type));

  Future<void> loadEmojis({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      state = EmojiState.initial(type: type);
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _userService.getEmojis(
        PageParams(
          page: state.page,
          limit: 5,
          type: type,
        ),
      );

      if (response.code == 1 && response.data != null) {
        final pageData = response.data!;
        final newList = [...state.emojis, ...pageData.list];

        state = state.copyWith(
          emojis: newList,
          page: state.page + 1,
          hasMore: newList.length < pageData.total,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.msg,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;
    await loadEmojis();
  }

  void reset() {
    state = EmojiState.initial(type: type);
  }
}

final emojiProvider = StateNotifierProvider.family<
    EmojiNotifier,
    EmojiState,
    int>((ref, type) {
  final userService = ref.read(userServiceProvider);
  return EmojiNotifier(userService, type);
});
