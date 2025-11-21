import 'package:flutter/material.dart';

import '../models/userinfo.dart';
import 'empty_retry.dart';
import 'user_list_item.dart';


class GeneralUserTab extends StatelessWidget {
  final bool loading;
  final List<UserInfo> results;
  final bool isLoaded;
  final VoidCallback onRefresh;
  final VoidCallback onLoadMore;
  final bool finished;

  const GeneralUserTab({
    super.key,
    required this.loading,
    required this.results,
    required this.isLoaded,
    required this.onRefresh,
    required this.onLoadMore,
    required this.finished,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Colors.white,
      onRefresh: () async => onRefresh(),
      child: !isLoaded
          ? _buildFirstLoading()
          : loading && results.isEmpty
          ? _buildFirstLoading()
          : NotificationListener<ScrollNotification>(
              onNotification: _handleScroll,
              child: results.isEmpty ? _buildEmpty() : _buildList(context),
            ),
    );
  }

  Widget _buildFirstLoading() {
    return const Center(child: CircularProgressIndicator(color: Colors.white));
  }

  Widget _buildEmpty() {
    return Center(child: EmptyWithRetry(onRetry: onRefresh));
  }

  Widget _buildList(BuildContext context) {
    return ListView.separated(
      itemCount: results.length + (loading ? 1 : 0) + (finished ? 1 : 0),
      separatorBuilder: (_, __) => const Divider(color: Colors.white12),
      itemBuilder: (context, index) {
        if (loading && index == results.length) {
          return _buildLoadMoreIndicator();
        }

        if (finished && index == results.length + (loading ? 1 : 0)) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text("没有更多了", style: TextStyle(color: Colors.white)),
            ),
          );
        }

        final item = results[index];
        return UserListItem(user: item);
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
