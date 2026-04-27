import 'dart:async';

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
  final FutureOr<void> Function() onRefresh;
  final VoidCallback onLoadMore;
  final bool finished;
  final String? scrollStorageKey;
  final bool showCategory;
  final bool showDeleteButton;
  final bool showSeparators;
  final void Function(int index)? onDelete;

  const GeneralPostTab({
    super.key,
    required this.loading,
    required this.results,
    required this.isLoaded,
    required this.onRefresh,
    required this.onLoadMore,
    required this.finished,
    this.scrollStorageKey,
    this.showCategory = false,
    this.showDeleteButton = false,
    this.showSeparators = false,
    this.onDelete,
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
      key: scrollStorageKey == null
          ? null
          : PageStorageKey<String>(scrollStorageKey!),
      addAutomaticKeepAlives: false,
      itemCount: results.length + (loading ? 1 : 0) + (finished ? 1 : 0),
      separatorBuilder: (_, _) => showSeparators
          ? const Divider(color: Colors.white12)
          : const SizedBox.shrink(),
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
        if (showDeleteButton && onDelete != null) {
          return Stack(
            children: [
              ForumPostCard(post: item, showCategory: showCategory),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => onDelete!(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        return ForumPostCard(post: item, showCategory: showCategory);
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
