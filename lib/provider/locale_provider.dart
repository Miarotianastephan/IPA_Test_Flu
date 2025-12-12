import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/storage_config.dart';

final localeProvider = StateProvider<Locale>((ref) => const Locale('en'));

final initializeLocaleProvider = FutureProvider<void>((ref) async {
  final savedLang = await StorageService.instance.getValue<String>('lang');
  final langCode = savedLang ?? 'en';
  ref.read(localeProvider.notifier).state = Locale(langCode);
});
