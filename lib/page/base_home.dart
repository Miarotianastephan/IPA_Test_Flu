import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/audio.dart';
import 'package:live_app/models/manga.dart';
import 'package:live_app/models/roman.dart';
import 'package:live_app/page/mini_player_bar.dart';
import 'package:live_app/page/novel_grid.dart';
import 'package:live_app/page/search_novel_detail_page.dart';
import 'package:live_app/page/search_novel_page.dart';
import 'package:live_app/page/search_page.dart';
import 'package:live_app/page/track_player_page.dart';
import 'package:live_app/provider/audio_provider.dart';
import 'package:live_app/provider/conversation_list_provider.dart';
import 'package:live_app/provider/cumulative_watch_time_provider.dart';
import 'package:live_app/provider/current_audio_provider.dart';
import 'package:live_app/provider/behavior_tracker_provider.dart';
import 'package:live_app/provider/current_tab_provider.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/provider/manga_provider.dart';
import 'package:live_app/provider/roman_provider.dart';
import 'package:live_app/utils/utils.dart';
import 'package:live_app/widgets/blur_widget.dart';
import 'package:live_app/widgets/download_banner.dart';
import 'package:live_app/widgets/draggable_fab.dart';
import 'package:live_app/widgets/empty_widget.dart';
import 'package:live_app/widgets/lazy_indexed_stack.dart';
import 'package:live_app/widgets/tiktok_scaffold.dart';
import 'package:live_app/widgets/video/category_novel_overlay_manager.dart';

import '../../widgets/video/video_tag_category_overlay.dart';
import '../utils/platform_check.dart';

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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(switchTabRequestProvider, (prev, next) {
      if (prev != next) Future(() => ref.trackPageVisit());
      if (next >= 0 && next < widget.pages.length) {
        setState(() => _currentIndex = next);
        ref.read(currentTabIndexProvider.notifier).state = next;
        // widget.controller.enableGesture = (next == 0);
        ref.read(switchTabRequestProvider.notifier).state = -1;
      }
    });

    final themeData = Theme.of(context);
    final unread = ref.watch(totalUnreadCountProvider);
    final i18nNotifier = ref.read(i18nNotifierProvider.notifier);
    final currentAudio = ref.watch(currentAudioProvider);
    final isAudioHome = widget.title == i18nNotifier.translate("audio");
    final showFloating = ref.watch(showFloatingButtonProvider);
    final isOnAdPage = ref.watch(isOnAdPageProvider);
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
                if (item is Audio) {
                  return item.audioCategory.name.isNotEmpty
                      ? item.audioCategory.name
                      : item.ref;
                }
                return "Autre";
              })
              .toSet()
              .toList()
        : [];
    final coverUrl =
        currentAudio?.s3CoverUrl ??
        ((widget.tabItems != null &&
                widget.tabItems!.isNotEmpty &&
                widget.tabItems!.first is Audio)
            ? (widget.tabItems!.first as Audio).s3CoverUrl
            : null);

    final scaffoldBody = LazyIndexedStack(
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
                            padding: const EdgeInsets.only(top: 20.0),
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
                                      if (item is Audio) {
                                        return Tab(
                                          text:
                                              item.audioCategory.name.isNotEmpty
                                              ? item.audioCategory.name
                                              : item.ref,
                                        );
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
                                  } else {
                                    CategoryOverlayManager.show(
                                      context: context,
                                      onClose: CategoryOverlayManager.hide,
                                      vsync: this,
                                      categoryProvider: audioCategoriesProvider,
                                      loadCategories: () {
                                        return ref.refresh(
                                          audioCategoriesProvider.future,
                                        );
                                      },
                                    );
                                  }
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
                        if (item is Audio) {
                          return (item.audioCategory.name.isNotEmpty
                                  ? item.audioCategory.name
                                  : item.ref) ==
                              cat;
                        }
                        return false;
                      }).toList();
                      final isAudioCategory =
                          filtered.isNotEmpty && filtered.first is Audio;
                      return filtered.isEmpty
                          ? const EmptyWidget()
                          : NovelGrid(
                              items: filtered,
                              isAudio: isAudioCategory,
                              showCreatorInfo: true,
                            );
                    }).toList(),
                  ),
                );
              },
            ),
          )
        : scaffoldBody;

    return Scaffold(
      body: Stack(
        children: [
          TikTokScaffold(
            currentTabIndex: _currentIndex,
            controller: widget.controller,
            hasBottomPadding: true,
            tabBar: BlurWidget(
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: PlatformCheck.isWebIOS ? 20.0 : 0,
                  ),
                  child: Row(
                    children: List.generate(widget.navItems.length, (index) {
                      final item = widget.navItems[index];
                      final isSelected = index == _currentIndex;
                      final isMessageTab = item["key"] == translate("message");
                      return Expanded(
                        child: InkWell(
                          onTap: () {
                            if (false &&
                                widget.navItems[index]["key"] == "message" &&
                                !ref.hasPermission(Permission.accessImFree)) {
                              showPermissionDeniedDialog(
                                context,
                                ref,
                                Permission.accessImFree,
                              );
                              return;
                            }
                            if (_currentIndex == 0 && index != 0) {
                              ref
                                  .read(cumulativeWatchTimeProvider.notifier)
                                  .stopTracking();
                            }
                            setState(() => _currentIndex = index);
                            ref.read(currentTabIndexProvider.notifier).state =
                                index;
                            // widget.controller.enableGesture = (index == 0);
                            ref.read(currentTabProvider.notifier).state =
                                item is Manga && item is Roman && item is Audio
                                ? false
                                : (index == 0);
                            ref.trackPageVisit();
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
            ),
            rightPage: widget.rightPage,
            page: body,
          ),
          if (currentAudio != null && isAudioHome && _currentIndex == 0)
            Positioned(
              left: 20,
              right: 20,
              bottom: 80 + MediaQuery.of(context).padding.bottom,
              child: GestureDetector(
                onTap: () {
                  final tracksList =
                      currentAudio.album?.tracks ?? currentAudio.tracks;

                  final currentIndex = tracksList.indexWhere(
                    (t) => t.id == currentAudio.id,
                  );
                  final safeIndex = currentIndex >= 0 ? currentIndex : 0;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TrackPlayerPage(
                        initialIndex: safeIndex,
                        audio: currentAudio,
                        tracks: tracksList,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Card(
                    color: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: MiniPlayerBar(
                      currentAudio: currentAudio,
                      tracks: currentAudio.album?.tracks ?? currentAudio.tracks,
                      initialIndex:
                          (currentAudio.album?.tracks ?? currentAudio.tracks)
                                  .indexWhere((t) => t.id == currentAudio.id) >=
                              0
                          ? (currentAudio.album?.tracks ?? currentAudio.tracks)
                                .indexWhere((t) => t.id == currentAudio.id)
                          : 0,
                      onClose: () {
                        ref.read(showFloatingButtonProvider.notifier).state =
                            true;
                      },
                    ),
                  ),
                ),
              ),
            ),
          showFloating && isAudioHome && _currentIndex == 0
              ? DraggableFab(
                  key: const ValueKey("fab"),
                  cover: coverUrl,
                  onPressed: () {
                    final audio =
                        currentAudio ??
                        (widget.tabItems != null &&
                                widget.tabItems!.isNotEmpty &&
                                widget.tabItems!.first is Audio
                            ? widget.tabItems!.first as Audio
                            : null);

                    if (audio != null) {
                      ref.read(currentAudioProvider.notifier).state = audio;
                      ref.read(showFloatingButtonProvider.notifier).state =
                          false;
                    }
                  },
                )
              : const SizedBox.shrink(),
          (kIsWeb &&
                  (defaultTargetPlatform == TargetPlatform.iOS ||
                      defaultTargetPlatform == TargetPlatform.android) &&
                  Uri.base.queryParameters['deviceType'] != 'ios' &&
                  !isOnAdPage)
              ? AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  bottom: kToolbarHeight + (_currentIndex == 0 ? 110 : 20),
                  left: 16,
                  right: 16,
                  child: const DownloadBanner(),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
