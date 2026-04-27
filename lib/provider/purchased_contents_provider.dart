import 'package:flutter_riverpod/flutter_riverpod.dart';

class PurchasedContentNotifier extends StateNotifier<Map<String, Set<String>>> {
  PurchasedContentNotifier() : super({});

  void markAsPurchased(String contentType, String contentId) {
    final currentSet = state[contentType] ?? {};
    state = {
      ...state,
      contentType: {...currentSet, contentId},
    };
  }

  bool isPurchased(String contentType, String contentId) {
    return state[contentType]?.contains(contentId) ?? false;
  }

  void removePurchased(String contentType, String contentId) {
    final currentSet = state[contentType];
    if (currentSet == null) return;

    final newSet = currentSet.where((id) => id != contentId).toSet();
    state = {...state, contentType: newSet};
  }

  void clear() {
    state = {};
  }

  void clearType(String contentType) {
    final newState = Map<String, Set<String>>.from(state);
    newState.remove(contentType);
    state = newState;
  }

  void initializeFromMap(Map<String, List<String>> purchasedContent) {
    state = purchasedContent.map((key, value) => MapEntry(key, value.toSet()));
  }

  void initializeFromList(String contentType, List<String> contentIds) {
    state = {...state, contentType: contentIds.toSet()};
  }

  Set<String> getPurchasedIds(String contentType) {
    return state[contentType] ?? {};
  }

  void markMultipleAsPurchased(String contentType, List<String> contentIds) {
    final currentSet = state[contentType] ?? {};
    state = {
      ...state,
      contentType: {...currentSet, ...contentIds},
    };
  }
}

final purchasedContentProvider =
    StateNotifierProvider<PurchasedContentNotifier, Map<String, Set<String>>>((
      ref,
    ) {
      return PurchasedContentNotifier();
    });

final isContentPurchasedProvider = Provider.family<bool, (String, String)>((
  ref,
  params,
) {
  final (contentType, contentId) = params;
  final purchasedContent = ref.watch(purchasedContentProvider);
  return purchasedContent[contentType]?.contains(contentId) ?? false;
});
