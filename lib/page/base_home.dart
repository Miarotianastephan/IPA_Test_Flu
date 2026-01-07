import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:live_app/provider/app_config_provider.dart';
import 'package:live_app/widgets/encrypted_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/manga.dart';
import 'package:live_app/models/roman.dart';
import 'package:live_app/page/novel_grid.dart';
import 'package:live_app/page/search_novel_detail_page.dart';
import 'package:live_app/page/search_novel_page.dart';
import 'package:live_app/page/search_page.dart';
import 'package:live_app/provider/conversation_list_provider.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/provider/manga_provider.dart';
import 'package:live_app/provider/roman_provider.dart';
import 'package:live_app/widgets/blur_widget.dart';
import 'package:live_app/widgets/empty_widget.dart';
import 'package:live_app/widgets/tiktok_scaffold.dart';
import 'package:live_app/widgets/video/category_novel_overlay_manager.dart';
import '../../widgets/video/video_tag_category_overlay.dart';

class BaseHome extends ConsumerStatefulWidget {
  final List<Widget> pages;
  final List<Map<String, dynamic>> navItems;
  final TikTokScaffoldController controller;
  final Widget? rightPage;
  final List<dynamic>? tabItems;
  final String? title;
  const BaseHome({
    super.key,
    required this.pages,
    required this.navItems,
    required this.controller,
    this.rightPage,
    this.tabItems,
    this.title,
  });

  @override
  ConsumerState<BaseHome> createState() => _BaseHomeState();
}

class _BaseHomeState extends ConsumerState<BaseHome>
    with TickerProviderStateMixin {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final unread = ref.watch(totalUnreadCountProvider);
    final i18nNotifier = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18nNotifier.translate(key);
    final categories = (widget.tabItems != null && _currentIndex == 0)
        ? widget.tabItems!
              .map((item) {
                if (item is Manga) {
                  return item.mangasCategory.name.isNotEmpty
                      ? item.mangasCategory.name
                      : item.ref;
                }
                if (item is Roman) {
                  return item.category.name;
                }
                return "Autre";
              })
              .toSet()
              .toList()
        : [];
    final scaffoldBody = IndexedStack(
      index: _currentIndex,
      children: widget.pages,
    );
    final body = (widget.tabItems != null && _currentIndex == 0)
        ? DefaultTabController(
            length: categories.length,
            child: Builder(
              builder: (context) {
                final outerController = DefaultTabController.of(context);
                outerController.addListener(() {
                  if (TagCategoryOverlay.isShown) {
                    TagCategoryOverlay.hide();
                  }
                });

                return Scaffold(
                  backgroundColor: Colors.black,
                  appBar: AppBar(
                    backgroundColor: Colors.black,
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (widget.title != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Text(
                              widget.title!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                        Row(
                          children: [
                            Expanded(
                              child: TabBar(
                                controller: outerController,
                                isScrollable: true,
                                tabAlignment: TabAlignment.start,
                                tabs:
                                    widget.tabItems?.map((item) {
                                      if (item is Manga) {
                                        return Tab(
                                          text:
                                              item
                                                  .mangasCategory
                                                  .name
                                                  .isNotEmpty
                                              ? item.mangasCategory.name
                                              : item.ref,
                                        );
                                      }
                                      if (item is Roman) {
                                        return Tab(text: item.category.name);
                                      }
                                      return const Tab(text: "");
                                    }).toList() ??
                                    [],
                                indicatorSize: TabBarIndicatorSize.label,
                                indicator: const BoxDecoration(),
                                labelColor: Colors.white,
                                labelStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                unselectedLabelStyle: const TextStyle(
                                  fontSize: 14,
                                  color: Color.fromRGBO(255, 255, 255, 0.8),
                                ),
                              ),
                            ),

                            IconButton(
                              icon: const Icon(
                                Icons.more_horiz,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                if (widget.title == "Vidéo" ||
                                    widget.title!.isEmpty ||
                                    widget.title == null) {
                                  if (TagCategoryOverlay.isShown) {
                                    TagCategoryOverlay.hide();
                                  } else {
                                    TagCategoryOverlay.show(
                                      context: context,
                                      onClose: TagCategoryOverlay.hide,
                                      vsync: this,
                                    );
                                  }
                                } else if (widget.title == translate("manga")) {
                                  if (CategoryOverlayManager.isShown) {
                                    CategoryOverlayManager.hide();
                                  } else {
                                    CategoryOverlayManager.show(
                                      context: context,
                                      onClose: CategoryOverlayManager.hide,
                                      vsync: this,
                                      categoryProvider: mangaCategoriesProvider,
                                      loadCategories: () {
                                        return ref.refresh(
                                          mangaCategoriesProvider.future,
                                        );
                                      },
                                    );
                                  }
                                } else if (widget.title == translate("roman")) {
                                  if (CategoryOverlayManager.isShown) {
                                    CategoryOverlayManager.hide();
                                  } else {
                                    CategoryOverlayManager.show(
                                      context: context,
                                      onClose: CategoryOverlayManager.hide,
                                      vsync: this,
                                      categoryProvider: romanCategoriesProvider,
                                      loadCategories: () {
                                        return ref.refresh(
                                          romanCategoriesProvider.future,
                                        );
                                      },
                                    );
                                  }
                                } else if (widget.title == translate("audio")) {
                                  if (CategoryOverlayManager.isShown) {
                                    CategoryOverlayManager.hide();
                                  } else {}
                                }
                              },
                            ),

                            IconButton(
                              icon: const Icon(
                                Icons.search,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                if (widget.title == translate("manga")) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => NovelSearchPage(
                                        type: SearchType.manga,
                                      ),
                                    ),
                                  );
                                } else if (widget.title == translate("roman")) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => NovelSearchPage(
                                        type: SearchType.roman,
                                      ),
                                    ),
                                  );
                                } else if (widget.title == translate("audio")) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => NovelSearchPage(
                                        type: SearchType.audio,
                                      ),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SearchPage(),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  body: TabBarView(
                    children: categories.map((cat) {
                      final filtered = widget.tabItems!.where((item) {
                        if (item is Manga) {
                          return (item.mangasCategory.name.isNotEmpty
                                  ? item.mangasCategory.name
                                  : item.ref) ==
                              cat;
                        }
                        if (item is Roman) {
                          return item.category.name == cat;
                        }
                        return false;
                      }).toList();
                      return filtered.isEmpty
                          ? const EmptyWidget()
                          : NovelGrid(items: filtered, showCreatorInfo: true);
                    }).toList(),
                  ),
                );
              },
            ),
          )
        : scaffoldBody;

    return TikTokScaffold(
      controller: widget.controller,
      hasBottomPadding: false,
      tabBar: BlurWidget(
        child: SafeArea(
          top: false,
          child: Row(
            children: List.generate(widget.navItems.length, (index) {
              final item = widget.navItems[index];
              final isSelected = index == _currentIndex;
              final isMessageTab = item["key"] == "message";

              return Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() => _currentIndex = index);
                    widget.controller.enableGesture = (index == 0);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 6),
                      isMessageTab && unread > 0
                          ? Badge.count(
                              count: unread,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              alignment: Alignment.topRight,
                              offset: const Offset(10, -6),
                              child: Icon(
                                item["icon"] as IconData,
                                size: 30,
                                color: isSelected
                                    ? themeData
                                          .bottomNavigationBarTheme
                                          .selectedItemColor
                                    : themeData
                                          .bottomNavigationBarTheme
                                          .unselectedItemColor,
                              ),
                            )
                          : Icon(
                              item["icon"] as IconData,
                              size: 30,
                              color: isSelected
                                  ? themeData
                                        .bottomNavigationBarTheme
                                        .selectedItemColor
                                  : themeData
                                        .bottomNavigationBarTheme
                                        .unselectedItemColor,
                            ),
                      Text(
                        item["label"] as String,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: isSelected
                              ? themeData
                                    .bottomNavigationBarTheme
                                    .selectedItemColor
                              : themeData
                                    .bottomNavigationBarTheme
                                    .unselectedItemColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
      rightPage: widget.rightPage,
      page: Stack(
        children: [
          body,
          if (kIsWeb &&
              (defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.android))
            Positioned(
              bottom: kToolbarHeight + 10,
              left: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.secondary.withAlpha(200),
                      Theme.of(context).colorScheme.secondary.withAlpha(250),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      launchUrl(Uri.parse("https://landing.99sq20.fun/"));
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: EncryptedImage(
                                url:
                                    ref
                                        .read(appConfigProvider)
                                        .data?["favicon_url"] ??
                                    "",
                                height: 44,
                                width: 44,
                                fit: BoxFit.cover,
                                errorWidget: Image.asset(
                                  "lib/assets/logo.jpg",
                                  height: 44,
                                  width: 44,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "XO App",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  translate("getFullExperience"),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              translate("download"),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
