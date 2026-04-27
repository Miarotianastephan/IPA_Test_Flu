import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/api/services/user_service.dart';
import 'package:live_app/models/content_bought.dart';
import 'package:live_app/provider/api_provider.dart';

class MyPurchasedState {
  final List<ContentBought> list;
  final bool isLoading;
  final bool hasMore;
  final int page;
  final String? error;

  const MyPurchasedState({
    this.list = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.page = 1,
    this.error,
  });

  MyPurchasedState copyWith({
    List<ContentBought>? list,
    bool? isLoading,
    bool? hasMore,
    int? page,
    String? error,
  }) {
    return MyPurchasedState(
      list: list ?? this.list,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      error: error,
    );
  }
}

class MyPurchasedNotifier extends StateNotifier<MyPurchasedState> {
  final UserService _userService;
  final String type;

  MyPurchasedNotifier(this._userService, this.type)
    : super(const MyPurchasedState()) {
    loadPurchases(refresh: true);
  }

  Future<void> loadPurchases({bool refresh = false}) async {
    if (state.isLoading && !refresh) return;

    if (refresh) {
      state = const MyPurchasedState(isLoading: true);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final currentPage = refresh ? 1 : state.page;

      final response = await _userService.findContentBought(
        type: type,
        page: currentPage,
        limit: 20,
      );

      if (response.data != null) {
        final pageResponse = response.data!;
        final newList = refresh
            ? pageResponse.list
            : [...state.list, ...pageResponse.list];
        final totalPages = (pageResponse.total / pageResponse.limit).ceil();

        state = state.copyWith(
          list: newList,
          isLoading: false,
          hasMore: currentPage < totalPages,
          page: currentPage + 1,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final myPurchasedProvider =
    StateNotifierProvider.family<MyPurchasedNotifier, MyPurchasedState, String>(
      (ref, type) {
        final userService = ref.watch(userServiceProvider);
        return MyPurchasedNotifier(userService, type);
      },
    );
