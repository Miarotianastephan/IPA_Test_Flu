import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/utils/app_lang_version_utils.dart';

class SortTab {
  final Tab tab;
  final String type;

  const SortTab(this.tab, this.type);
}

List<SortTab> getSortTabs(WidgetRef ref) {
  final i18n = ref.read(i18nNotifierProvider.notifier);
  return [
    SortTab(Tab(text: i18n.translate('sortLatest')), "latest"),
    SortTab(Tab(text: i18n.translate('sortHot')), "sortHot"),
    SortTab(Tab(text: i18n.translate('sortLike')), "sortLike"),
    SortTab(Tab(text: i18n.translate('sortFavorite')), "sortFavorite"),
    SortTab(Tab(text: i18n.translate('sortComment')), "sortComment"),
    SortTab(Tab(text: i18n.translate('sortDuration')), "sortDuration"),
    SortTab(Tab(text: i18n.translate('bought')), "isBought"),
  ];
}

Widget getSortTabBar(TabController? tabController, WidgetRef ref) {
  final tabs = getSortTabs(ref);
  return TabBar(
    controller: tabController,
    isScrollable: false,
    padding: const EdgeInsets.only(bottom: 10),
    labelPadding: const EdgeInsets.symmetric(horizontal: 8),
    indicatorColor: Colors.white,
    labelColor: Colors.white,
    unselectedLabelColor: Colors.grey,
    labelStyle: TextStyle(
      fontSize: (AppLangVersionUtils.isCn() || AppLangVersionUtils.isTk()) ? 13 : 11,
      fontWeight: FontWeight.bold,
    ),
    tabs: tabs.map((e) => e.tab).toList(),
  );
}
