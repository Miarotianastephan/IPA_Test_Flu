import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentTabProvider = StateProvider<bool>((ref) => true);

final currentTabIndexProvider = StateProvider<int>((ref) => 0);

final gameTabIndexProvider = StateProvider<int>((ref) => -1);

final switchTabRequestProvider = StateProvider<int>((ref) => -1);

final pendingGameUrlProvider = StateProvider<String?>((ref) => null);

final profileTabIndexProvider = StateProvider<int>((ref) => -1);

final profileTabSectionProvider = StateProvider<int?>((ref) => null);

final isOnAdPageProvider = StateProvider<bool>((ref) => false);
