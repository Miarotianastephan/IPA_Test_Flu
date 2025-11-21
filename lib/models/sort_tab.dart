import 'package:flutter/material.dart';
import 'package:live_app/l10n/app_localizations.dart';

class SortTab {
  final Tab tab;
  final String type;

  const SortTab(this.tab, this.type);
}

List<SortTab> getSortTabs(BuildContext context) {
  return [
    SortTab(Tab(text: AppLocalizations.of(context)!.sortLatest), "latest"),
    SortTab(Tab(text: AppLocalizations.of(context)!.sortHot), "hot"),
    SortTab(Tab(text: AppLocalizations.of(context)!.sortLike), "like"),
    SortTab(Tab(text: AppLocalizations.of(context)!.sortFavorite), "favorite"),
    SortTab(Tab(text: AppLocalizations.of(context)!.sortComment), "comment"),
    SortTab(Tab(text: AppLocalizations.of(context)!.sortDuration), "duration"),
  ];
}

Widget getSortTabBar(BuildContext context, TabController? tabController) {
  final tabs = getSortTabs(context);
  return TabBar(
    controller: tabController,
    isScrollable: false,
    padding: const EdgeInsets.only(bottom: 10),
    labelPadding: const EdgeInsets.symmetric(horizontal: 8),
    indicatorColor: Colors.redAccent,
    labelColor: Colors.white,
    unselectedLabelColor: Colors.grey,
    labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    tabs: tabs.map((e) => e.tab).toList(),
  );
}
