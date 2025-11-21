import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/forum_post.dart';
import '../../models/page_params.dart';
import '../../models/api_response.dart';
import '../provider/api_provider.dart';
import '../widgets/empty_retry.dart';
import '../widgets/forum/forum_post_card.dart';


class ForumTagCategoryPage extends ConsumerStatefulWidget {
  final String title;
  final String type;
  final int id;

  const ForumTagCategoryPage({
    super.key,
    required this.title,
    required this.type,
    required this.id,
  });

  @override
  ConsumerState<ForumTagCategoryPage> createState() =>
      _ForumTagCategoryPageState();
}

class _ForumTagCategoryPageState extends ConsumerState<ForumTagCategoryPage> {
  final ScrollController _scrollController = ScrollController();
  List<ForumPost> _posts = [];
  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _loadData().then((_) {
      if (mounted) setState(() {});
    });
    _scrollController.addListener(_onScroll);
  }

  Future<ApiResponse<dynamic>> _loadData() async {
    final forumService = ref.read(forumServiceProvider);
    final params = PageParams(page: _page);

    final res = widget.type == "tag"
        ? await forumService.forums(pageParams: params, tagId: widget.id)
        : await forumService.forums(pageParams: params, categoryId: widget.id);

    final newItems = (res.data?.list ?? []);

    if (_page == 1) {
      _posts = newItems;
    } else {
      _posts.addAll(newItems);
    }

    _total = res.data?.total ?? 0;
    _hasMore = _posts.length < _total && newItems.isNotEmpty;

    return res;
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _refresh() async {
    _page = 1;
    _hasMore = true;
    _posts.clear();
    await _loadData();
    if (mounted) setState(() {});
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;
    _isLoading = true;
    _page++;
    await _loadData();
    _isLoading = false;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black,
      ),
      body: RefreshIndicator(
        color: Colors.white,
        onRefresh: _refresh,
        child: (_total == 0 && !_isLoading)
            ? EmptyWithRetry(
          onRetry: _refresh,
        )
            : ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _posts.length + 1,
          itemBuilder: (_, index) {
            if (index == _posts.length) {
              if (!_hasMore) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      "没有更多了",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              }

              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              );
            }

            final post = _posts[index];
            return ForumPostCard(
              post: post,
            );
          },
        ),
      ),
    );
  }
}