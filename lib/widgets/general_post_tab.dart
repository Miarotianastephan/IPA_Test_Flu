import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/i18n_provider.dart';

import '../models/forum_post.dart';
import 'empty_retry.dart';
import 'forum/forum_post_card.dart';

class GeneralPostTab extends ConsumerWidget {
  final bool loading;
  final List<ForumPost> results;
  final bool isLoaded;
  final VoidCallback onRefresh;
  final VoidCallback onLoadMore;
  final bool finished;

  const GeneralPostTab({
    super.key,
    required this.loading,
    required this.results,
    required this.isLoaded,
    required this.onRefresh,
    required this.onLoadMore,
    required this.finished,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      color: Colors.white,
      onRefresh: () async => onRefresh(),
      child: !isLoaded
          ? _buildFirstLoading() // 只有首次、且确实在 loading 时全屏转圈
          : loading && results.isEmpty
          ? _buildFirstLoading()
          : NotificationListener<ScrollNotification>(
              onNotification: (scroll) => _handleScroll(scroll),
              child: results.isEmpty ? _buildEmpty() : _buildList(context, ref),
            ),
    );
  }

  Widget _buildFirstLoading() {
    return const Center(child: CircularProgressIndicator(color: Colors.white));
  }

  Widget _buildEmpty() {
    return Center(child: EmptyWithRetry(onRetry: onRefresh));
  }

  Widget _buildList(BuildContext context, WidgetRef ref) {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    return ListView.separated(
      itemCount: results.length + (loading ? 1 : 0) + (finished ? 1 : 0),
      separatorBuilder: (_, __) => const Divider(color: Colors.white12),
      itemBuilder: (context, index) {
        if (loading && index == results.length) {
          return _buildLoadMoreIndicator();
        }

        if (finished && index == results.length + (loading ? 1 : 0)) {
          return Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                i18n.translate('noMore'),
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        final item = results[index];
        return ForumPostCard(post: item);
      },
    );
  }

  Widget _buildLoadMoreIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  bool _handleScroll(ScrollNotification scroll) {
    if (isLoaded &&
        !loading &&
        results.isNotEmpty &&
        scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 300) {
      onLoadMore();
    }
    return false;
  }
}
