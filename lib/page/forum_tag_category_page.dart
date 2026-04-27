import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/forum_post.dart';
import '../../models/page_params.dart';
import '../provider/api_provider.dart';
import '../widgets/general_post_tab.dart';

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
  List<ForumPost> _posts = [];
  int _page = 1;
  bool _isLoading = false;
  bool _isLoaded = false;
  bool _hasMore = true;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_loadData());
  }

  Future<void> _loadData() async {
    final forumService = ref.read(forumServiceProvider);
    final params = PageParams(page: _page);

    _isLoading = true;
    if (mounted) {
      setState(() {});
    }

    try {
      final res = widget.type == "tag"
          ? await forumService.forums(pageParams: params, tagId: widget.id)
          : await forumService.forums(
              pageParams: params,
              categoryId: widget.id,
            );

      final newItems = (res.data?.list ?? []);

      if (_page == 1) {
        _posts = newItems;
      } else {
        _posts.addAll(newItems);
      }

      _total = res.data?.total ?? 0;
      _hasMore = _posts.length < _total && newItems.isNotEmpty;
    } finally {
      _isLoading = false;
      _isLoaded = true;
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _refresh() async {
    _page = 1;
    _hasMore = true;
    _posts.clear();
    await _loadData();
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;
    _page++;
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text(widget.title), backgroundColor: Colors.black),
      body: GeneralPostTab(
        loading: _isLoading,
        results: _posts,
        isLoaded: _isLoaded,
        onRefresh: _refresh,
        onLoadMore: () {
          unawaited(_loadMore());
        },
        finished: !_hasMore,
      ),
    );
  }
}
