import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/constants/ad_placement.dart';
import 'package:live_app/provider/ad_provider.dart';
import 'package:live_app/provider/app_config_provider.dart';
import 'package:live_app/provider/forum_category_tag_provider.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/widgets/ad_banner_carousel.dart';
import 'package:live_app/widgets/empty_retry.dart';
import 'package:live_app/widgets/forum/ad_post_card.dart';
import 'package:live_app/widgets/forum/forum_category_specific_tags.dart';

import '../../models/forum_category.dart';
import '../../models/forum_filter.dart';
import '../../models/forum_post.dart';
import '../../models/page_params.dart';
import '../../provider/api_provider.dart';
import '../../widgets/forum/forum_post_card.dart';
import '../../widgets/tiktok_scaffold.dart';
import '../forum_category_page.dart';
import '../forum_tag_category_page.dart';
import '../search_page.dart';

class ForumTabPage extends ConsumerStatefulWidget {
  final TikTokScaffoldController? tkcontroller;

  const ForumTabPage({super.key, this.tkcontroller});

  @override
  ConsumerState<ForumTabPage> createState() => _ForumTabPageState();
}

class _ForumTabPageState extends ConsumerState<ForumTabPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  bool _loading = true;
  bool _bannerClosed = false;
  List<ForumPost> _posts = [];
  List<ForumCategory> _categories = [];
  List<ForumCategory> _subCategories = [];
  int _selectedCategory = 0;
  String _currentFilter = "recent";

  int _page = 1;
  final ScrollController _postScrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    Future.microtask(() async {
      ref
          .read(adListProvider(AdPlacement.communityTopBanner).notifier)
          .fetch(refresh: true);
      ref
          .read(adListProvider(AdPlacement.communityFeed).notifier)
          .fetch(refresh: true);
    });

    _postScrollController.addListener(() {
      if (_postScrollController.position.pixels >=
              _postScrollController.position.maxScrollExtent -
                  _postScrollController.position.viewportDimension &&
          !_isLoadingMore &&
          _hasMore &&
          !_loading) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _postScrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    //final i18n = ref.read(i18nNotifierProvider.notifier);
    final service = ref.read(forumServiceProvider);
    try {
      final res = await service.categories();
      final trimmedTopCategories = (res.data ?? [])
          .take(5)
          .map(
            (category) => ForumCategory(
              id: category.id,
              name: category.name,
              parentId: category.parentId,
              children: (category.children ?? []).take(5).toList(),
            ),
          )
          .toList();
      setState(() {
        // _categories =
        //     [ForumCategory(id: 0, name: i18n.translate('all'))] +
        //     trimmedTopCategories.take(5).toList();
        _categories = trimmedTopCategories.take(4).toList();
        _subCategories = _categories.isNotEmpty
            ? (_categories[0].children ?? [])
            : [];
        _tabController?.dispose();
        _tabController = TabController(length: _categories.length, vsync: this);
        _tabController!.addListener(() {
          if (!_tabController!.indexIsChanging) {
            final index = _tabController!.index;
            setState(() {
              _selectedCategory = index;
              _subCategories = _categories[index].children ?? [];
            });
            _fetchPosts(
              categoryId: _categories[index].id,
              sort: "latest",
              forumFilter: _currentFilter,
            );
            _loadCategoryTags(_categories[index].id);
          }
        });
      });
      _fetchPosts(
        categoryId: _categories[0].id,
        sort: "latest",
        forumFilter: _currentFilter,
      );
      _loadCategoryTags(_categories[0].id);
    } catch (e) {}
  }

  void _loadCategoryTags(int? categoryId) {
    ref
        .read(forumCategoryTagProvider(categoryId?.toString()).notifier)
        .fetch(refresh: true, limit: 999);
  }

  Future<void> _fetchPosts({
    int categoryId = 0,
    String sort = "latest",
    String? forumFilter,
  }) async {
    setState(() {
      _loading = true;
      _page = 1;
      _hasMore = true;
    });
    final service = ref.read(forumServiceProvider);
    try {
      final filterValue = forumFilter ?? _currentFilter;
      final res = await service.forums(
        pageParams: PageParams(page: _page, limit: 20),
        sort: sort,
        categoryId: categoryId,
        forumFilter: ForumFilter(
          recent: filterValue == "recent",
          selection: filterValue == "selection",
          video: filterValue == "video",
        ),
      );

      setState(() {
        _posts = res.data?.list ?? [];
        _hasMore = (res.data?.list.length ?? 0) == 20;
      });
    } catch (e) {
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    final service = ref.read(forumServiceProvider);
    try {
      _page += 1;
      final res = await service.forums(
        pageParams: PageParams(page: _page, limit: 20),
        categoryId: _categories[_selectedCategory].id == 0
            ? null
            : _categories[_selectedCategory].id,
        forumFilter: ForumFilter(
          recent: _currentFilter == "recent",
          selection: _currentFilter == "selection",
          video: _currentFilter == "video",
        ),
      );
      final newPosts = res.data?.list ?? [];
      setState(() {
        _posts.addAll(newPosts);
        if (newPosts.length < 20) _hasMore = false;
      });
    } catch (e) {
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  bool _isAdSlot(int displayIndex, int adsToInsert, int adsAfter) {
    if (adsToInsert == 0 || adsAfter <= 0) return false;
    if ((displayIndex + 1) % (adsAfter + 1) != 0) return false;
    final adIndex = (displayIndex + 1) ~/ (adsAfter + 1) - 1;
    return adIndex < adsToInsert;
  }

  int _getAdIndex(int displayIndex, int adsAfter) {
    return (displayIndex + 1) ~/ (adsAfter + 1) - 1;
  }

  int _getPostIndex(int displayIndex, int adsAfter, int adsToInsert) {
    if (adsAfter <= 0) return displayIndex;
    final adsBeforeThis = _isAdSlot(displayIndex, adsToInsert, adsAfter)
        ? _getAdIndex(displayIndex, adsAfter)
        : (_getAdIndex(displayIndex, adsAfter) + 1).clamp(0, adsToInsert);
    return displayIndex - adsBeforeThis;
  }

  int _getAdsToInsert(int postCount, int adCount, int adsAfter) {
    if (postCount == 0 || adCount == 0 || adsAfter <= 0) return 0;
    final maxAdsToInsert = postCount ~/ adsAfter;
    return maxAdsToInsert < adCount ? maxAdsToInsert : adCount;
  }

  @override
  Widget build(BuildContext context) {
    final adState = ref.watch(adListProvider(AdPlacement.communityTopBanner));
    final feedAdState = ref.watch(adListProvider(AdPlacement.communityFeed));
    final adsAfter = ref.watch(appConfigProvider).data?.adsAfter ?? 5;
    final int adCount = feedAdState.list.length;
    final int adsToInsert = adsAfter > 0
        ? _getAdsToInsert(_posts.length, adCount, adsAfter)
        : 0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            // 分类分区选择栏
            if (_tabController != null)
              Container(
                height: 57,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        tabs: _categories
                            .map((t) => Tab(text: t.name))
                            .toList(),
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
                      icon: const Icon(Icons.list, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ForumCategoryPage(),
                          ),
                        );
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SearchPage()),
                        );
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

            if (_subCategories.isNotEmpty)
              Container(
                height: 34,
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _subCategories.length,
                  itemBuilder: (context, index) {
                    final sub = _subCategories[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ForumTagCategoryPage(
                              title: sub.name,
                              type: "category",
                              id: sub.id,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade900,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade700),
                        ),
                        child: Text(
                          sub.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              const SizedBox.shrink(),

            if (adState.list.isNotEmpty && !_bannerClosed) ...[
              const SizedBox(height: 8),
              AdBannerCarousel(
                ads: adState.list,
                onClose: () => setState(() => _bannerClosed = true),
              ),
              const SizedBox(height: 8),
            ],

            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : RefreshIndicator(
                      color: Colors.white,
                      onRefresh: () => _fetchPosts(
                        categoryId: _categories[_selectedCategory].id,
                        sort: _selectedCategory == 0 ? "recommend" : "latest",
                        forumFilter: _currentFilter,
                      ),
                      child: ListView.builder(
                        controller: _postScrollController,
                        padding: EdgeInsets.only(
                          top: 0,
                          bottom: MediaQuery.of(context).padding.bottom,
                        ),
                        itemCount: _posts.isEmpty
                            ? 3
                            : (_posts.length + adsToInsert + 3),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            if (_categories.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return ForumCategorySpecificTags(
                              categoryId: _categories[_selectedCategory].id == 0
                                  ? null
                                  : _categories[_selectedCategory].id,
                            );
                          }
                          if (index == 1) {
                            final i18n = ref.read(
                              i18nNotifierProvider.notifier,
                            );
                            return Padding(
                              padding: const EdgeInsets.only(
                                top: 15,
                                right: 10,
                                left: 10,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildFilterButton(
                                    "recent",
                                    i18n.translate("filterRecent"),
                                  ),
                                  _buildFilterButton(
                                    "selection",
                                    i18n.translate("filterSelection"),
                                  ),
                                  _buildFilterButton(
                                    "video",
                                    i18n.translate("filterVideo"),
                                  ),
                                ],
                              ),
                            );
                          }
                          if (_posts.isEmpty && index == 2) {
                            return SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: EmptyWithRetry(
                                onRetry: () => _fetchPosts(
                                  categoryId: _categories[_selectedCategory].id,
                                  sort: "latest",
                                ),
                              ),
                            );
                          }

                          final displayIndex = index - 1;

                          if (_isAdSlot(displayIndex, adsToInsert, adsAfter)) {
                            final adIndex = _getAdIndex(displayIndex, adsAfter);
                            if (adIndex < feedAdState.list.length) {
                              return AdPostCard(ad: feedAdState.list[adIndex]);
                            }
                            return const SizedBox.shrink();
                          }

                          final postIndex = _getPostIndex(
                            displayIndex,
                            adsAfter,
                            adsToInsert,
                          );
                          if (postIndex >= _posts.length || postIndex < 0) {
                            final totalItems = _posts.length + adsToInsert + 3;
                            if (index != totalItems - 1) {
                              return const SizedBox.shrink();
                            }
                            if (!_hasMore) {
                              final i18n = ref.read(
                                i18nNotifierProvider.notifier,
                              );
                              return Padding(
                                padding: const EdgeInsets.all(16),
                                child: Center(
                                  child: Text(
                                    i18n.translate('noMore'),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              );
                            }
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            );
                          }

                          return ForumPostCard(
                            post: _posts[postIndex],
                            showCategory: _selectedCategory == 0,
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String filterValue, String label) {
    final isActive = _currentFilter == filterValue;

    return GestureDetector(
      onTap: () {
        if (_currentFilter == filterValue) return;

        setState(() => _currentFilter = filterValue);

        _fetchPosts(
          categoryId: _categories.isNotEmpty
              ? _categories[_selectedCategory].id
              : 0,
          sort: "latest",
          forumFilter: filterValue,
        );
      },
      child: Container(
        width: 70,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.grey.shade900 : null,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isActive
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
