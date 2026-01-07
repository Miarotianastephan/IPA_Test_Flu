import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/api/services/roman_service.dart';
import 'package:live_app/models/roman.dart';
import 'package:live_app/models/roman_category.dart';
import 'package:live_app/provider/api_provider.dart';

final romanServiceProvider = Provider<RomanService>((ref) {
  final client = ref.read(apiClientProvider);
  return RomanService(client);
});

final romanProvider = FutureProvider<List<Roman>>((ref) async {
  final service = ref.read(romanServiceProvider);
  final resp = await service.romans();

  if (resp.code != 1) {
    throw Exception('Erreur API: ${resp.code}');
  }

  final data = resp.data;
  if (data == null) throw Exception("RomanResponse is null");

  return data.roman;
});

final romanCategoriesProvider = FutureProvider<List<RomanCategory>>((
  ref,
) async {
  final service = ref.read(romanServiceProvider);
  final resp = await service.romans();
  if (resp.code != 1) {
    throw Exception('Erreur API: ${resp.code}');
  }

  final data = resp.data;
  if (data == null) {
    throw Exception("RomanResponse is null");
  }

  return data.roman.map((r) {
    final cat = r.category;
    return RomanCategory(id: cat.id, name: cat.name);
  }).toList();
});
