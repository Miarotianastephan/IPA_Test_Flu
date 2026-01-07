import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/emoji.dart';

import '../repository/emoji_repository.dart';

class EmojiState {
  final List<Emoji> emojis;
  final bool isLoading;
  final bool isSyncing;
  final int type;
  final String? error;

  EmojiState({
    required this.emojis,
    required this.isLoading,
    required this.isSyncing,
    required this.type,
    this.error,
  });

  factory EmojiState.initial({int type = 1}) {
    return EmojiState(
      emojis: [],
      isLoading: false,
      isSyncing: false,
      type: type,
    );
  }

  EmojiState copyWith({
    List<Emoji>? emojis,
    bool? isLoading,
    bool? isSyncing,
    int? type,
    String? error,
  }) {
    return EmojiState(
      emojis: emojis ?? this.emojis,
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      type: type ?? this.type,
      error: error,
    );
  }
}

class EmojiNotifier extends StateNotifier<EmojiState> {
  final EmojiRepository _repository;
  final int type;

  EmojiNotifier(this._repository, this.type)
    : super(EmojiState.initial(type: type)) {
    _loadFromCache();
    _syncInBackground();
  }

  Future<void> _loadFromCache() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final cached = await _repository.getEmojis(type);

      state = state.copyWith(emojis: cached, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> _syncInBackground() async {
    if (state.isSyncing) return;

    state = state.copyWith(isSyncing: true);

    try {
      final synced = await _repository.syncEmojis(type);

      if (synced) {
        final updated = await _repository.getEmojis(type);
        state = state.copyWith(emojis: updated);
      }
    } catch (e) {
      debugPrint('[EmojiNotifier] Background sync error: $e');
    } finally {
      state = state.copyWith(isSyncing: false);
    }
  }

  Future<void> refresh() async {
    if (state.isLoading || state.isSyncing) return;

    state = state.copyWith(isSyncing: true, error: null);

    try {
      await _repository.syncEmojis(type, forceRefresh: true);

      final updated = await _repository.getEmojis(type);
      state = state.copyWith(emojis: updated, isSyncing: false);
    } catch (e) {
      state = state.copyWith(isSyncing: false, error: e.toString());
    }
  }

  Future<bool> checkForUpdates() async {
    try {
      return await _repository.hasUpdates(type);
    } catch (e) {
      return false;
    }
  }

  Future<void> clearCache() async {
    await _repository.clearCache(type);
    state = EmojiState.initial(type: type);
  }

  void reset() {
    state = EmojiState.initial(type: type);
  }
}

final emojiProvider =
    StateNotifierProvider.family<EmojiNotifier, EmojiState, int>((ref, type) {
      final repository = ref.read(emojiRepositoryProvider);
      return EmojiNotifier(repository, type);
    });
