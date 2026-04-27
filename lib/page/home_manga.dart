import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/manga.dart';
import 'package:live_app/page/base_home.dart';
import 'package:live_app/page/home_tab/message_page.dart';
import 'package:live_app/page/home_tab/profile_page.dart';
import 'package:live_app/page/novel_grid.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/widgets/tiktok_scaffold.dart';

class HomeMangaPage extends ConsumerWidget {
  final List<Manga> items;
  final Map<String, dynamic>? config;
  const HomeMangaPage({super.key, required this.items, this.config});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = TikTokScaffoldController();
    String translate(String key) =>
        ref.read(i18nNotifierProvider.notifier).translate(key);

    final pages = [
      NovelGrid(items: items, isAudio: false),
      if (config?['chat_enable'] == true) MessageTabPage(appConfig: config),
      const ProfileTabPage(origin: ProfileOrigin.manga),
    ];

    final navItems = [
      {"icon": Icons.home, "label": translate("home")},
      if (config?['chat_enable'] == true)
        {
          "icon": Icons.bubble_chart,
          "label": translate("message"),
          "key": "message",
        },
      {"icon": Icons.person, "label": translate("profile")},
    ];
    return BaseHome(
      pages: pages,
      navItems: navItems,
      controller: controller,
      tabItems: items,
      title: translate("manga"),
    );
  }
}
