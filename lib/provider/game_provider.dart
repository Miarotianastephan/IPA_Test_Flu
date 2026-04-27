import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/api/services/game_service.dart';
import 'package:live_app/models/game.dart';
import 'package:live_app/provider/api_provider.dart';
import 'package:live_app/utils/utils.dart';

class GameListState {
  final List<Game> games;
  final bool isLoading;
  final String? error;
  final bool hasMore;

  GameListState({
    this.games = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
  });

  GameListState copyWith({
    List<Game>? games,
    bool? isLoading,
    String? error,
    bool? hasMore,
  }) {
    return GameListState(
      games: games ?? this.games,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class GameListNotifier extends StateNotifier<GameListState> {
  final GameService gameService;

  int _currentPage = 1;
  final int _limit = 20;

  GameListNotifier(this.gameService) : super(GameListState());

  Future<void> loadGames({bool refresh = false}) async {
    if (state.isLoading) return;
    if (!refresh && !state.hasMore) return;

    if (refresh) {
      _currentPage = 1;
      state = state.copyWith(isLoading: true, games: [], hasMore: true);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }
    debugPrint("load games");
    try {
      final resp = await gameService.getGameList(
        page: _currentPage,
        limit: _limit,
      );
      debugPrint("load games response: $resp");
      final data = resp.data;
      if (data == null) throw Exception("Response data null");

      final newList = refresh ? data.list : [...state.games, ...data.list];

      final bool stillMore =
          newList.length < data.total && data.list.length == _limit;

      state = state.copyWith(games: newList, hasMore: stillMore, error: null);

      if (stillMore) {
        _currentPage++;
      }
    } catch (e) {
      debugPrint("load games error: $e");
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<String?> loginGame() async {
    try {
      final deviceId = getDeviceId();
      debugPrint("login game device id: $deviceId");
      final resp = await gameService.gameLogin(deviceId);
      debugPrint("login game response: $resp");
      if (resp.data != null) {
        debugPrint("login game data: ${resp.data}");
        final url = resp.data!;
        if (url.startsWith('http://') || url.startsWith('https://')) {
          return url;
        }
        debugPrint("login game: invalid URL returned: $url");
        return null;
      }
      return null;
    } catch (e) {
      debugPrint("login game error: $e");
      return null;
    }
  }

  void reset() {
    _currentPage = 1;
    state = GameListState();
  }
}

final gameListProvider = StateNotifierProvider<GameListNotifier, GameListState>(
  (ref) {
    final client = ref.watch(apiClientProvider);
    return GameListNotifier(GameService(client));
  },
);
