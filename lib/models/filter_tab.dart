import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/i18n_provider.dart';

class FilterTab {
  final Tab tab;
  final int type;

  const FilterTab(this.tab, this.type);
}

List<FilterTab> getFilterTabs(WidgetRef ref) {
  final i18n = ref.read(i18nNotifierProvider.notifier);
  return [
    FilterTab(Tab(text: i18n.translate('filterWatching')), 1),
    FilterTab(Tab(text: i18n.translate('filterLatest')), 2),
    FilterTab(Tab(text: i18n.translate('filterHot')), 3),
    FilterTab(Tab(text: "VIP"), 4),
    FilterTab(Tab(text: i18n.translate('filterRandom')), 5),
  ];
}

TabBar getFilterTabBar(TabController? tabController, BuildContext context, WidgetRef ref) {
  return TabBar(
    controller: tabController,
    isScrollable: false,
    padding: EdgeInsets.only(bottom: 10),
    labelPadding: const EdgeInsets.symmetric(horizontal: 8),
    indicatorColor: Colors.white,
    labelColor: Colors.white,
    unselectedLabelColor: Colors.grey,
    labelStyle: TextStyle(
      fontSize:
          Localizations.localeOf(context).languageCode == 'en' ||
              Localizations.localeOf(context).languageCode == 'es'
          ? 14
          : 16,
      fontWeight: FontWeight.bold,
    ),
    tabs: getFilterTabs(ref).map((e) => e.tab).toList(),
  );
}
