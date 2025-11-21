import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/l10n/app_localizations.dart';
import 'package:live_app/widgets/empty_retry.dart';
import '../../models/forum_post.dart';
import '../../models/forum_category.dart';
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
  final ScrollController _categoryScrollController = ScrollController();
  final List<GlobalKey> _categoryKeys = [];
  bool _loading = true;
  List<ForumPost> _posts = [];
  List<ForumCategory> _categories = [];
  List<ForumCategory> _subCategories = [];
  int _selectedCategory = 0;

  int _page = 1;
  final ScrollController _postScrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
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
    _categoryScrollController.dispose();
    _postScrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
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
        _categories =
            [ForumCategory(id: 0, name: AppLocalizations.of(context)!.all)] +
            trimmedTopCategories.take(5).toList();
        _subCategories = _categories.isNotEmpty
            ? (_categories[0].children ?? [])
            : [];
        _categoryKeys
          ..clear()
          ..addAll(List.generate(_categories.length, (_) => GlobalKey()));
      });
      _fetchPosts(categoryId: 0, sort: "recommend");
    } catch (e) {
      debugPrint("加载分类失败: $e");
    }
  }

  Future<void> _fetchPosts({int categoryId = 0, String sort = "latest"}) async {
    setState(() {
      _loading = true;
      _page = 1;
      _hasMore = true;
    });
    final service = ref.read(forumServiceProvider);
    debugPrint("88888888888888888888888888888888888${categoryId}8888888888888888888888888888888888888888");
    try {
      final res = await service.forums(
        pageParams: PageParams(page: _page, limit: 20),
        sort: sort,
        categoryId: categoryId,
      );
      
      setState(() {
        _posts = res.data?.list ?? [];
        _hasMore = (res.data?.list.length ?? 0) == 20;
      });
    } catch (e) {
      debugPrint("加载帖子失败: $e");
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
      );
      final newPosts = res.data?.list ?? [];
      setState(() {
        _posts.addAll(newPosts);
        if (newPosts.length < 20) _hasMore = false;
      });
    } catch (e) {
      debugPrint("加载更多失败: $e");
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            // 分类分区选择栏
            Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _categoryScrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final selected = index == _selectedCategory;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = index;
                              _subCategories =
                                  _categories[index].children ?? [];
                            });
                            _fetchPosts(
                              categoryId: _categories[index].id,
                              sort: "latest",
                            );
                            final keyContext =
                                _categoryKeys[index].currentContext;
                            if (keyContext != null) {
                              final box =
                                  keyContext.findRenderObject() as RenderBox;
                              final position = box.localToGlobal(
                                Offset.zero,
                                ancestor: context.findRenderObject(),
                              );
                              final screenWidth = MediaQuery.of(
                                context,
                              ).size.width;
                              final itemCenter =
                                  position.dx + box.size.width / 2;
                              final offset =
                                  _categoryScrollController.offset +
                                  itemCenter -
                                  screenWidth / 2;

                              _categoryScrollController.animateTo(
                                offset.clamp(
                                  0,
                                  _categoryScrollController
                                      .position
                                      .maxScrollExtent,
                                ),
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOutCubic,
                              );
                            }
                          },
                          child: Container(
                            key: _categoryKeys[index],
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: selected
                                  ? Colors.grey.shade200
                                  : Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _categories[index].name,
                              style: TextStyle(
                                color: selected ? Colors.black87 : Colors.white,
                                fontWeight: selected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.list, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForumCategoryPage(), // 新页面
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
              const SizedBox(height: 8),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : _posts.isEmpty
                  ? EmptyWithRetry(
                      onRetry: () => _fetchPosts(
                        categoryId: _categories[_selectedCategory].id,
                        sort: "latest",
                      ),
                    )
                  : RefreshIndicator(
                      color: Colors.white,
                      onRefresh: () => _fetchPosts(
                        categoryId: _categories[_selectedCategory].id,
                        sort: "latest",
                      ),
                      child: ListView.builder(
                        controller: _postScrollController,
                        padding: EdgeInsets.only(
                          top: 0,
                          bottom: MediaQuery.of(context).padding.bottom,
                        ),
                        itemCount: _posts.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _posts.length) {
                            if (!_hasMore) {
                              return Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: Text(
                                    AppLocalizations.of(context)!.noMore,
                                    style: TextStyle(color: Colors.white),
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
                          final post = _posts[index];
                          if (index == _posts.length - 1 && _isLoadingMore) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            );
                          }
                          return ForumPostCard(post: post);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
