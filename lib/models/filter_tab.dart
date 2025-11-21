import 'package:flutter/material.dart';
import 'package:live_app/l10n/app_localizations.dart';

class FilterTab {
  final Tab tab;
  final int type;

  const FilterTab(this.tab, this.type);
}

List<FilterTab> getFilterTabs(BuildContext context) {
  return [
    FilterTab(Tab(text: AppLocalizations.of(context)!.filterWatching), 1),
    FilterTab(Tab(text: AppLocalizations.of(context)!.filterLatest), 2),
    FilterTab(Tab(text: AppLocalizations.of(context)!.filterHot), 3),
    FilterTab(Tab(text: "VIP"), 4),
    FilterTab(Tab(text: AppLocalizations.of(context)!.filterRandom), 5),
  ];
}

getFilterTabBar(TabController? tabController, context) {
  return TabBar(
    controller: tabController,
    isScrollable: false,
    padding: EdgeInsets.only(bottom: 10),
    labelPadding: const EdgeInsets.symmetric(horizontal: 8),
    indicatorColor: Colors.redAccent,
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
    tabs: getFilterTabs(context).map((e) => e.tab).toList(),
  );
}
