import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/audio_provider.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/provider/manga_provider.dart';
import 'package:live_app/provider/roman_provider.dart';
import '../page/novel_grid.dart';

enum SearchType { manga, roman, audio }

class NovelSearchDetailPage extends ConsumerWidget {
  final String keyword;
  final SearchType type;

  const NovelSearchDetailPage({
    super.key,
    required this.keyword,
    required this.type,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const background = Colors.black;
    String translate(String key) =>
        ref.read(i18nNotifierProvider.notifier).translate(key);
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "\"$keyword\"",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: _buildBody(ref, translate),
    );
  }

  Widget _buildBody(WidgetRef ref, String Function(String) translate) {
    switch (type) {
      case SearchType.roman:
        final av = ref.watch(romanProvider);
        return av.when(
          data: (items) {
            final filtered = items.where((r) {
              return r.titles.any(
                (t) => t.title.toLowerCase().contains(keyword.toLowerCase()),
              );
            }).toList();

            if (filtered.isEmpty) {
              return Center(
                child: Text(
                  translate("noRomanFound"),
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
            return NovelGrid(
              items: filtered,
              isAudio: false,
              showCreatorInfo: true,
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text(
              "${translate("error")} : $e",
              style: const TextStyle(color: Colors.red),
            ),
          ),
        );

      case SearchType.manga:
        final av = ref.watch(mangaProvider);
        return av.when(
          data: (items) {
            final filtered = items.where((m) {
              return m.titles.any(
                (t) => t.title.toLowerCase().contains(keyword.toLowerCase()),
              );
            }).toList();

            if (filtered.isEmpty) {
              return Center(
                child: Text(
                  translate("noMangaFound"),
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
            return NovelGrid(
              items: filtered,
              isAudio: false,
              showCreatorInfo: true,
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text(
              "${translate("error")} : $e",
              style: const TextStyle(color: Colors.red),
            ),
          ),
        );

      case SearchType.audio:
        final av = ref.watch(audioProvider);
        return av.when(
          data: (items) {
            final filtered = items.where((a) {
              return a.titles.any(
                (t) => t.title.toLowerCase().contains(keyword.toLowerCase()),
              );
            }).toList();
            if (filtered.isEmpty) {
              return Center(
                child: Text(
                  translate("noAudioFound"),
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }
            return NovelGrid(
              items: filtered,
              isAudio: true,
              showCreatorInfo: true,
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text(
              "${translate("error")} : $e",
              style: const TextStyle(color: Colors.red),
            ),
          ),
        );
    }
  }
}
